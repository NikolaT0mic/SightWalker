import 'package:flutter/material.dart';

import '../services/tour_service.dart';
import '/views/route_page.dart';
import '/views/settings_page.dart';
import '/widgets/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool isLoading = false;

  var failText = "";
  
  var tour = [];
  var city = {};
  var start = {};
  
  List tourData = [];
  
  void setStart(var _start) {
    setState(() {
      start = _start; 
    });
  }

  void setCity(var _city) {
    setState(() {
      city = _city;
    });
  }

  Future<void> fetchData() async {
    TourService t = TourService();
    var temp = await t.requestTour(city, start);
    //print("Test tour desc ausgabe: ${temp[0]["name"]}");
    setState(() {
      tourData = temp;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
            const SizedBox(height: 30,),
            const Text("Select City", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 3, bottom: 3),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.amber),
                borderRadius: BorderRadius.circular(10.0),
              ),
              width: double.infinity,
              height: 40,
              child: SearchBarWidget(text: "Search City",searchType: "locality", setter: setCity)
            ),
            const SizedBox(height: 10,),
            const Text("Select starting point", style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 3, bottom: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: double.infinity,
                height: 40,
                child: SearchBarWidget(text: "Search Location", setter: setStart)
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
                onPressed: () async {
                  bool error = false;
                  setState(() {
                    failText = "";
                    isLoading = true;
                  });
                  try {
                    await fetchData();
                  } on Exception catch (_) {
                    error = true;
                    print('Fetch Data failed');
                    setState(() {
                      failText = "Tour creation failed";
                    });
                  }
                  setState(() {
                    isLoading = false;
                  });
                  if(!error) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RoutePage(tourData: tourData,),
                      ),
                    );
                  }
                },
                child: Text("Generate Tour")),
            const SizedBox(height: 20,),
            Center(
              child: !isLoading ? Container() : const CircularProgressIndicator(),
            ),
            Center(
              child: failText == "" ? Container() : Text(failText),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (context) => RoutePage(tourData: tourData,),
      //       ),
      //     );
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
