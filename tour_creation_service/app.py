from flask import Flask, request, jsonify

from city_tour_planer import Location, load_sights, prioritize_sights, plan_tour

app = Flask(__name__)


@app.route("/tour", methods=['POST'])
def route():
    """
    Creates a route.
    Expected json input:
    {
        "city_name": str,
        "city_lng": float,
        "city_lat": float,
        "start_name": str,
        "start_lng": float,
        "start_lat": float,
        "prioritized_sight_types": list[str],
        "max_time": int,
        "language": "en",
    }
    """
    data = request.get_json()
    city_lng = data["city_lng"]
    city_lat = data["city_lat"]
    city_name = data["city_name"]
    start_lng = data["start_lng"]
    start_lat = data["start_lat"]
    start_name = data["start_name"]
    city = Location(city_name, city_lat, city_lng)
    start = Location(start_name, start_lat, start_lng)
    sights = load_sights(city, language=data["language"])
    sights = prioritize_sights(sights, data["prioritized_sight_types"])
    tour = plan_tour(sights, int(data["max_time"]), starting_location=start)
    print("Best tour: ", [sight.name for sight in tour])
    return jsonify([sight.__dict__ for sight in tour])


def main():
    app.run(host="0.0.0.0", port=8080)


if __name__ == '__main__':
    main()
