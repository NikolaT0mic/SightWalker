import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  final String title = "Settings";

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          PreferenceList()
        ],
      ),
    );
  }
}

class PreferenceList extends StatefulWidget{

  @override
  State<PreferenceList> createState() => _PreferenceListState();
}

class _PreferenceListState extends State<PreferenceList> {
  List<String> items = [];
  static const String preferenceList = 'preferences';
  static const String name = 'Location Preferences';

  void loadPreferences() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      items = prefs.getStringList(preferenceList) ?? ['Amusement Park', 'Art Gallery', 'Church', 'Museum', 'Park', 'Zoo', 'University'];
    });
  }

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView(
      header: const Text(
          name,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20
          ),
      ),
      shrinkWrap: true,
      onReorder: _reorderItems,
      children:  items.map<Widget>((item) {
        var index = items.indexOf(item);
        return ListTile(
          key: ValueKey(index),
          title: Text(item),
          trailing: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
          onTap: () {},
        );
      }).toList(),
    );
  }

  _reorderItems(oldIndex, newIndex) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      if(newIndex > oldIndex) {
        newIndex--;
      }
      final item = items.removeAt(oldIndex);
      items.insert(newIndex, item);
      prefs.setStringList(preferenceList, items);
    });
  }
}
