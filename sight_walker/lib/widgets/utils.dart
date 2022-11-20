import 'dart:math' show cos, sqrt, asin;

/// in KM
double distance(start, end) {
  var lat1 = start["lat"];
  var lon1 = start["lng"];
  var lat2 = end["lat"];
  var lon2 = end["lng"];
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((lat2 - lat1) * p)/2 +
      c(lat1 * p) * c(lat2 * p) *
          (1 - c((lon2 - lon1) * p))/2;
  return 12742 * asin(sqrt(a));
}

int walkingTime(start, end) {
  var dist = distance(start, end);
  return (dist / 5 * 60 * 1.4).toInt();
}

String toTimeString(chillTime) {
  var hh = 0;
  var mm = 0;
  var timeString = "";
  if(chillTime>=60) {
    hh = chillTime ~/ 60;
    chillTime = chillTime - hh * 60;
    if (hh == 1) {
      timeString = "$hh hour";
    } else {
      timeString = "$hh hours";
    }
  }
  if(chillTime>0) {
    mm = chillTime;
    if(hh>0) {
      timeString = "$timeString and $mm minutes";
    } else {
      timeString = "$mm minutes";
    }
  }
  return timeString;
}

String parsePreference(String preference) {
  return preference.toLowerCase().replaceAll(" ", "_");
}