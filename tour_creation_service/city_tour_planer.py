import copy
import dataclasses
import json
import os.path

import geopy.distance as geodist
import googlemaps
import networkx as nx
from dacite import from_dict
from googleplaces import GooglePlaces
from networkx.algorithms.approximation import traveling_salesman_problem, greedy_tsp

from preferences import SightType, Minutes, get_time
from utils import powerset

API_KEY = 'AIzaSyDAkFS6Abq2m54nwZkUd9LEp3LRYMjU8I4'

google_places = GooglePlaces(API_KEY)
gmaps = googlemaps.Client(key=API_KEY)


@dataclasses.dataclass
class Place:
    name: str
    lat: float
    lng: float
    description: str | None = ""
    website: str | None = ""
    rating: float = 0.0
    ratings: int = 0
    types: list[str] = dataclasses.field(default_factory=lambda: [])
    score: float = 0.0
    estimated_time: Minutes = 0
    picture_url: str = ""

    def __hash__(self):
        return hash(self.name)

    def __eq__(self, other):
        if other is None:
            return False
        return self.name == other.name

    @classmethod
    def from_place(cls, place):
        summary = None
        if "editorial_summary" in place.details:
            summary = place.details["editorial_summary"]["overview"]

        photo_url = ""
        if place.photos:
            photo = place.photos[0]
            photo.get(maxheight=500, maxwidth=500)
            photo_url = photo.url

        return cls(
            name=place.name,
            lng=float(place.geo_location["lng"]),
            lat=float(place.geo_location["lat"]),
            description=summary,
            website=place.website,
            rating=float(place.rating),
            ratings=int(place.details['user_ratings_total']),
            types=place.types,
            score=float(place.rating) * int(place.details['user_ratings_total']),
            estimated_time=get_time(place.types),
            picture_url=photo_url
        )


Sight = Place
Location = Place

MUNICH = Place(name="Munich", lat=48.1351, lng=11.582)
STOCKHOLM = Place(name="Munich", lat=59.3293, lng=18.0686)


def get_sights(sights_result) -> list:
    sights = []
    for place in sights_result.places:
        if place.rating <= 4.0:
            continue

        place.get_details()
        sights.append(Sight.from_place(place))

    sights = scale_scores(sights)

    return sights


def load_sights_rec(location: Location, language: str, page_token=None, max_pages=1):
    sights_result = google_places.nearby_search(
        location=location.name.lower(),
        keyword='sights',
        radius=20000,
        types=["tourist_attraction"],
        lat_lng={'lat': location.lat, 'lng': location.lng},
        pagetoken=page_token,
        language=language
    )

    sight_data = get_sights(sights_result)
    if sights_result.has_next_page_token and max_pages - 1 >= 1:
        print(sights_result.next_page_token)
        sight_data += load_sights_rec(location, sights_result.next_page_token, max_pages - 1)

    return sight_data


def prioritize_sights(sorted_sights: list[Sight], sight_preferences: list[SightType]):
    sights = copy.deepcopy(sorted_sights)
    bonus = 25
    for preference in sight_preferences:
        for sight in sights:
            if preference in sight.types:
                sight.score += bonus
    scale_scores(sights)
    return sights


def scale_scores(sights: list[Sight]):
    sorted_sights = copy.deepcopy(sights)
    sorted_sights.sort(key=lambda sight: sight.score, reverse=True)

    min_score = sorted_sights[-1].score
    max_score = sorted_sights[0].score
    for sight in sorted_sights:
        sight.score = (sight.score - min_score) / (max_score - min_score) * 100

    return sorted_sights


def plan_tour(prioritized_sights: list[Sight],
              tour_time: Minutes,
              starting_location: Sight):
    """
    Heuristic function to find a good tour - this can be improved a lot in the future.
    Only considers walking atm
    """
    print("computing best route")

    prioritized_sights = prioritized_sights[0:15]
    prioritized_sights.append(starting_location)
    dist_graph = nx.Graph()
    for sight1 in prioritized_sights:
        for sight2 in prioritized_sights:
            if sight1 is sight2:
                continue
            approximated_walking_time = get_approximated_walking_time(sight1, sight2)

            dist_graph.add_edge(sight1, sight2, weight=approximated_walking_time)

    return get_best_round_trip(dist_graph, starting_location, tour_time)


def get_best_round_trip(sights_graph: nx.Graph, start: Sight, max_time: Minutes):
    """
    This is a traveling purchaser problem (TPP).
    https://en.wikipedia.org/wiki/Traveling_purchaser_problem
    Purchase: Pay with time, get utility (score)
    """
    best_route: list[Sight] = [start]
    possible_sight_combinations = list(powerset(sights_graph.nodes))
    for sight_combination in possible_sight_combinations:
        if start not in sight_combination or len(sight_combination) <= 2:
            # can not be a valid solution
            continue

        if sum([sight.estimated_time for sight in sight_combination]) >= max_time:
            # can not be a valid solution
            continue

        # now we have a TSP problem
        sight_combination = list(sight_combination)
        route = traveling_salesman_problem(sights_graph,
                                           weight='weight',
                                           nodes=sight_combination,
                                           cycle=True,
                                           method=greedy_tsp)

        total_time = get_time_for_route(route)

        # print("Route: ", [sight.name for sight in route], total_time, total_time > max_time)

        if total_time > max_time:
            continue

        utility = sum([sight.score for sight in set(route)])
        best_utility = sum([sight.score for sight in set(best_route)])
        if utility > best_utility:
            best_route = route

    # move start to beginning and remove last element => best_route = [start, ..., last stop before start]
    best_route = best_route[:-1]
    best_route = rotate_til(best_route, start)
    return best_route


def rotate_til(l: list[any], item: any) -> list[any]:
    if l[0] is item or item not in l:
        return l
    r = l.pop()
    l.insert(0, r)
    return rotate_til(l, item)


def get_time_for_route(route: list[Sight]):
    total_time = sum([sight.estimated_time for sight in set(route)])
    for i in range(0, len(route) - 2):
        total_time += get_approximated_walking_time(route[i], route[i + 1])
    return total_time


def get_approximated_walking_time(sight1: Sight, sight2: Sight):
    linear_distance = geodist.distance((sight1.lat, sight1.lng), (sight2.lat, sight2.lng))
    # * 1.4 is the approximate additional time needed from A to B as one can not walk linear distance
    return int(linear_distance.meters / 5000 * 60 * 1.4)


def save_sights(city: Location, sights: list[Sight], language):
    with open(f"sight_data/{city.name.lower()}_sights_{language}.json", "w") as file:
        file.write(json.dumps([sight.__dict__ for sight in sights], sort_keys=False, indent=4))


def load_sights(city: Location, language="en"):
    path = f"sight_data/{city.name.lower()}_sights_{language}.json"
    if not os.path.exists(path):
        print("loading sights")
        sights = load_sights_rec(location=city, language=language)
        save_sights(city, sights, language)
        return sights

    print("from preloaded")
    with open(path, "r") as file:
        data = json.load(file)
        return [from_dict(data_class=Sight, data=sight_dict) for sight_dict in data]
