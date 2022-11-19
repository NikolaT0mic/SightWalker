import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//TODO: move API key to a secure location
const API_KEY = "AIzaSyDAkFS6Abq2m54nwZkUd9LEp3LRYMjU8I4";

class MapView extends StatefulWidget {
  const MapView({super.key, required this.tourData});

  final List tourData;

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // Initial location of the Map view
  static CameraPosition _initialLocation = CameraPosition(target: LatLng(48.137154, 11.576124), zoom:13);
  // For controlling the view of the Map
  late GoogleMapController mapController;
  // Object for PolylinePoints
  late PolylinePoints polylinePoints;
  // List of coordinates to join
  List<LatLng> polylineCoordinates = [];
  // Map storing polylines created by connecting two points
  //Map<PolylineId, Polyline> polylines = {};
  List<Polyline> polys = [];
  List<Marker> markers = [];

  // This method will add markers to the map based on the LatLng position
  addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    markers.add(marker);
  }

  // Create the polylines for showing the route between two places
  createPolylines(
      double startLatitude,
      double startLongitude,
      double destLatitude,
      double destLongitude,
      int colorNr,
      ) async {
      // Initializing PolylinePoints
      polylinePoints = PolylinePoints();
      // Generating the list of coordinates to be used for
      // drawing the polylines
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        API_KEY, // Google Maps API Key
        PointLatLng(startLatitude, startLongitude),
        PointLatLng(destLatitude, destLongitude),
        travelMode: TravelMode.walking,
      );
      // Adding the coordinates to the list
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }
      // Defining an ID
      PolylineId id = PolylineId('poly');

      // Initializing Polyline
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: polylineCoordinates,
        width: 3,
      );
      // Adding the polyline to the map
      //polylines[id] = polyline;
      polys.add(polyline);
      setState(() {});
      return;
    }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void createLines() async {
    int colorNr = 0;
    var start = widget.tourData[0];
    _initialLocation =  CameraPosition(target: LatLng(start["lat"], start["lng"]), zoom:13);
    addMarker(LatLng(start["lat"], start["lng"]), start["name"], BitmapDescriptor.defaultMarkerWithHue(90));
    if (widget.tourData.length == 1) {
      return;
    }
    var next = widget.tourData[1];
    addMarker(LatLng(next["lat"], next["lng"]), next["name"], BitmapDescriptor.defaultMarker);
    await createPolylines(start["lat"], start["lng"], next["lat"], next["lng"], colorNr++);
    print(start["name"]);
    print(next["name"]);
    for (int i = 2; i < widget.tourData.length; i++) {
      var prev = next;
      next = widget.tourData[i];
      addMarker(LatLng(next["lat"], next["lng"]), next["name"], BitmapDescriptor.defaultMarker);
      await createPolylines(prev["lat"], prev["lng"], next["lat"], next["lng"], colorNr++);
      print(prev["name"]);
      print(next["name"]);
      if (i == widget.tourData.length - 1) {
        await createPolylines(next["lat"], next["lng"], start["lat"], start["lng"], colorNr++);
        print(next["name"]);
        print(start["name"]);
      }
    }
  }

  @override
  void initState() {
    print("Route");
    for (var loc in widget.tourData) {
      print(loc["name"]);
    }
    print("end route");
    createLines();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Determining the screen width & height
    var height = (MediaQuery.of(context).size.height)/2;
    var width = MediaQuery.of(context).size.width;


    return Container(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              markers: Set<Marker>.of(markers),
              polylines: Set<Polyline>.of(polys),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          mini: true,
          onPressed:() => mapController.animateCamera(
            CameraUpdate.newCameraPosition(_initialLocation),
          ),
          child: const Icon(Icons.center_focus_strong),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      ),
    );
  }
}