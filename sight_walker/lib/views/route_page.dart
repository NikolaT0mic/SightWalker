import 'package:flutter/material.dart';
import 'package:sight_walker/widgets/route_sight_list.dart';
import 'package:sight_walker/widgets/route_sight_tile.dart';
import '../widgets/utils.dart';
import 'settings_page.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key, required this.tourData});

  final List tourData;

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {

  late List<bool> isOpen = List.filled(widget.tourData.length, false);

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
            Column(
              children: routeList(widget.tourData, isOpen),
            )
          ],
        ),
      ),
    );
  }
}