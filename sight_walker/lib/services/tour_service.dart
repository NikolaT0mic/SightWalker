import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/utils.dart';


class TourService{

  Future<List> requestTour(var city, var start) async {
    //get preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> preferredSights = prefs.getStringList('preferences')
        ?? ['museum', 'park', 'amusement_park', 'art_gallery', 'church', 'zoo', 'university'];
    preferredSights = preferredSights.map((preference) => parsePreference(preference)).toList();

    var url = "https://2cc7-2a09-80c0-192-0-d3a8-8f12-9ddf-3f34.eu.ngrok.io/tour";
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer 2HlluFUp2EHieRPiOgQJLfNG7oX_6GxQS3V8kgkRcqouSpLGi'
    };
    var request = http.Request('POST', Uri.parse(url));
    request.body = json.encode({
      "city_name": city["description"],
      "city_lng": city["lng"],
      "city_lat": city["lat"],
      "start_name": start["description"],
      "start_lng": start["lng"],
      "start_lat": start["lat"],
      "prioritized_sight_types": preferredSights,
      "max_time": 180,
      "language": "en"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      //print(await response.stream.bytesToString());
      var tourData = jsonDecode(await response.stream.bytesToString());
      print(tourData);
      return tourData;
    }
    else {
      print(response.reasonPhrase);
      throw Exception("Request failed");
    }
  }
}