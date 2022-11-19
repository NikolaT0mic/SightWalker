import 'package:flutter/material.dart';

import 'settings_page.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key, required this.tourData});

  final List tourData;

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {

  List<bool> isOpen = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sight Tour"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.settings)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(10.0),
              ),
              alignment: Alignment.centerLeft,
              height: 400,
              width: double.infinity,
              margin: const EdgeInsets.all(15.0),
              padding: const EdgeInsets.all(5.0),
              child: Text(widget.tourData[0]["name"]),
            ),
            ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  isOpen[index] = !isExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return Row(children: const [
                      Flexible(flex: 2,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Text("Stachus"),
                          )
                      ),
                      SizedBox(width: 30,),
                      Flexible(flex: 1,
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Text("5 min"),
                          )
                      ),
                    ]);
                  },
                  isExpanded: isOpen[0],
                  body: Column(
                    children: [
                      Row(children: const [
                        Flexible(flex: 1,
                            child: Padding(
                              padding: EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Image(image: NetworkImage("https://picsum.photos/250?image=9")),
                            )
                        ),
                        SizedBox(width: 20,),
                        Flexible(flex: 2, child: Text("Erklärung")),
                      ],),
                      const SizedBox(height: 20,),
                      Container(
                        height: 30,
                          width: double.infinity,
                          decoration: const BoxDecoration(color: Colors.blueGrey),
                          child: const Text("Audio")
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}