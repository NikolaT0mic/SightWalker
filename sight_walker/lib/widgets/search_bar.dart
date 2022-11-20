import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:google_maps_webservice/places.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key, required this.text, required this.setter, this.searchType = ""});

  final String text;
  final String searchType;
  final Function setter;

  @override
  State<SearchBarWidget> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBarWidget> {

  String googleApikey = "AIzaSyDAkFS6Abq2m54nwZkUd9LEp3LRYMjU8I4";
  /// TODO pass place to parent
  String location = "";
  String lat = "0";
  String lon = "0";
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: "AIzaSyDAkFS6Abq2m54nwZkUd9LEp3LRYMjU8I4");

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // show input autocomplete with selected mode
        // then get the Prediction selected
        Prediction? p = await PlacesAutocomplete.show(
          types: [widget.searchType],
            context: context, apiKey: googleApikey);
        displayPrediction(p);
      },
      child: Text(location == "" ? widget.text : location),
    );
  }

  Future<void> displayPrediction(Prediction? p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId!);

      double? lat = detail.result.geometry?.location.lat;
      double? lng = detail.result.geometry?.location.lng;

      setState(() {
        location = p.description!;
        widget.setter({"description": p.description, "lng": lng, "lat": lat});
      });
    }
  }
}