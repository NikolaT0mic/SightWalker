import 'package:flutter/material.dart';
import 'utils.dart';

String truncateOrPadString(String inputString) {
  if (inputString.length <= 30) {
    print(30 - inputString.length);
    return inputString.padRight(30 - inputString.length);
  }
  return "${inputString.substring(0, 27)}...";
}

Future<void> _showMyDialog(context, badge) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: Center(child: Text(badge["title"])),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Image.network(badge["img"]),
              Center(child: Text(badge["description"])),
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      );
    },
  );
}

IgnorePointer routeTile(Map sightInfo, {bool expandable = true}) {
  String sightName = sightInfo["name"];
  String picUrl = sightInfo["picture_url"];
  int chillTime = sightInfo["estimated_time"];
  String desc = sightInfo["description"];
  Map badge = sightInfo["badge"];
  final ValueNotifier<MaterialStatePropertyAll<Color>> color = ValueNotifier<MaterialStatePropertyAll<Color>>(MaterialStatePropertyAll(Colors.blue));

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
          ValueListenableBuilder<MaterialStatePropertyAll<Color>>(
            builder: (BuildContext context, MaterialStatePropertyAll<Color> value, Widget? child) {
              // This builder will only get called when the _counter
              // is updated.
              return ElevatedButton(onPressed: () {
                color.value = MaterialStatePropertyAll(Colors.green);
                if(badge.isNotEmpty) {
                  _showMyDialog(context, badge);
                }
              }, style: ButtonStyle(
                backgroundColor: color.value,
              ) ,child: Text("Visited"));
            },
            valueListenable: color,
          )
        ]),
      ],
    ),
  );
}
