import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  final String title = "Settings";

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () {print("ahh");}, icon: Icon(Icons.share_location))
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber),
              borderRadius: BorderRadius.circular(10.0),
            ),
            alignment: Alignment.centerLeft,
            height: 40,
            width: double.infinity,
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(5.0),
            child: const Text("This is just a test"),
          ),
        ],
      ),
    );
  }
}
