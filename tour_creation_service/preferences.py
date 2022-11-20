from enum import Enum

Minutes = int


class TravelMode(str, Enum):
    WALKING = "walking"
    TRAIN = "train"
    BUS = "bus"
    CAB = "cab"


class SightType(str, Enum):
    MUSEUM = "museum"
    PARK = "park"
    CHURCH = "church"
    ZOO = "zoo"
    GALLERY = "art_gallery"
    AMUSEMENT_PARK = "amusement_park"


sight_times: dict[SightType, Minutes] = {
    SightType.MUSEUM: 90,
    SightType.GALLERY: 90,
    SightType.PARK: 60,
    SightType.AMUSEMENT_PARK: 120,
    SightType.ZOO: 180,
    SightType.CHURCH: 15
}


def get_time(sight_types: list[SightType]):
    for sight_type in sight_types:
        if sight_type in sight_times:
            return sight_times[sight_type]
    return 15
