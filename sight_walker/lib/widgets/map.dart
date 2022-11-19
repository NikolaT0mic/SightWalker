import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//TODO: move API key to a secure location
const API_KEY = "AIzaSyDAkFS6Abq2m54nwZkUd9LEp3LRYMjU8I4";

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // Initial location of the Map view (München)
  static const CameraPosition _initialLocation = CameraPosition(target: LatLng(48.137154, 11.576124), zoom:13);
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
      double destLongitude
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
        width: 5,
      );
      // Adding the polyline to the map
      //polylines[id] = polyline;
      polys.add(polyline);
      setState(() {});
    }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    addMarker(LatLng(48.1527, 11.5919), "origin", BitmapDescriptor.defaultMarkerWithHue(90));
    addMarker(LatLng(48.1357, 11.5718), "wp", BitmapDescriptor.defaultMarker);
    addMarker(LatLng(48.1299, 11.5835), "end", BitmapDescriptor.defaultMarker);
    createPolylines(48.1527, 11.5919, 48.1357, 11.5718);
    createPolylines(48.1357, 11.5718, 48.1299, 11.5835);
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