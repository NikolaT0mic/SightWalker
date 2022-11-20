import 'package:flutter/material.dart';
import 'package:sight_walker/widgets/route_sight_list.dart';
import '../widgets/map.dart';
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
            MapView(tourData: widget.tourData),
            Column(children: routeList(widget.tourData, isOpen)),
          ],
        ),
      ),
    );
  }
}