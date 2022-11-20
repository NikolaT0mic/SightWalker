import 'package:flutter/material.dart';
import 'utils.dart';

String truncateOrPadString(String inputString) {
  if (inputString.length <= 30) {
    print(30 - inputString.length);
    return inputString.padRight(30 - inputString.length);
  }
  return "${inputString.substring(0, 27)}...";
}

IgnorePointer routeTile(Map sightInfo, {bool expandable = true}) {
  String sightName = sightInfo["name"];
  String picUrl = sightInfo["picture_url"];
  int chillTime = sightInfo["estimated_time"];
  String desc = sightInfo["description"];
  Map badge = sightInfo["badge"];
  var visited = sightInfo["visited"];

  String timeString = toTimeString(chillTime);

  sightName = truncateOrPadString(sightName);

  return IgnorePointer(
    ignoring: !expandable,
    child: ExpansionTile(
      trailing: expandable
          ? const Icon(Icons.arrow_drop_down)
          : const SizedBox.shrink(),
      title: Row(children: [
        Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(sightName),
            )),
        const SizedBox(
          width: 30,
        ),
        Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(timeString),
            )),
      ]),
      children: [
        Row(
          children: [
            Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: picUrl == ""
                      ? Container()
                      : Image(image: NetworkImage(picUrl)),
                )),
            const SizedBox(
              width: 20,
            ),
            Flexible(flex: 2, child: Text(desc)),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
            height: 30,
            width: double.infinity,
            decoration: const BoxDecoration(color: Colors.blueGrey),
            child: const Text("Audio")),
        Row(children: [
          const Text("Visited: "),
          const SizedBox(width: 20,),
          // Checkbox(
          //   value: visited,
          //   onChanged: (bool value) {
          //     sightInfo["visited"] = value;
          //   },
          // ),
        ]),
      ],
    ),
  );
}
