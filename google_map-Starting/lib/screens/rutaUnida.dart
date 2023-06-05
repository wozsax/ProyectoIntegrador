import 'dart:convert';



import 'package:flutter/material.dart';
import 'package:google_mao/screens/perfil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

import 'package:uuid/uuid.dart';
import 'package:firebase_database/firebase_database.dart';



extension on double {
  double toRadians() => this * (pi / 180);
}




const String API_KEY = 'AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI'; // Put your Google Maps API Key here

class RutaUnida extends StatefulWidget {

  final String uniqueCode;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final String route;
  final String hour;
  final String carModel;

  RutaUnida({required this.markers, required this.polylines, required this.route, required this.hour, required this.carModel})
      : uniqueCode = Uuid().v4().substring(0, 4);  // Generate the unique code here

  @override
  _RutaUnidaState createState() => _RutaUnidaState();
}

class _RutaUnidaState extends State<RutaUnida> {
  late String _uniqueCode;
  final _routeController = TextEditingController();
  final _hourController = TextEditingController();
  final _carModelController = TextEditingController();
  late GoogleMapController _controller;
  bool _controllerReady = false;
  late Set<Marker> _markers;
  late Set<Polyline> _polylines;

  @override
  void initState() {
    super.initState();
    _routeController.text = widget.route;
    _hourController.text = widget.hour;
    _carModelController.text = widget.carModel;
    _markers = widget.markers;
    _polylines = widget.polylines;
    _uniqueCode = widget.uniqueCode;

    _addExistingPointInMiddle();
    print("Unique Code: ${widget.uniqueCode}");
    createRouteRecord(widget.route, _markers, _polylines, widget.hour, widget.carModel);
  }
  final databaseReference = FirebaseDatabase.instance.reference();

  void createRouteRecord(
      String routeName, Set<Marker> markers, Set<Polyline> polylines, String hour, String carModel) {
    final DatabaseReference databaseReference = FirebaseDatabase.instance.reference();

    // Save the route information to the database using the unique code
    databaseReference.child("routes").child(_uniqueCode).set({
      'name': routeName,
      'markers': markers.map((marker) => marker.toJson()).toList(),
      'polylines': polylines.map((polyline) => polyline.toJson()).toList(),
      'hour': hour,
      'carModel': carModel,
    });
  }




  void _addExistingPointInMiddle() async {
    List<Marker> sortedMarkers = _markers.toList()
      ..sort((a, b) {
        return _calculateDistance([a.position, _markers.first.position]).compareTo(
            _calculateDistance([b.position, _markers.first.position]));
      });

    Marker middleMarker = sortedMarkers[sortedMarkers.length ~/ 2];

    List<LatLng> polylinePoints = await _getRouteCoordinates(
        _markers.first.position, middleMarker.position);

    polylinePoints.addAll(await _getRouteCoordinates(
        middleMarker.position, sortedMarkers.last.position));

    setState(() {
      _polylines = {
        Polyline(
          polylineId: PolylineId('route'),
          color: Colors.blue,
          points: polylinePoints,
        )
      };
    });

    _animateCameraToBounds();
  }

  Future<void> _animateCameraToBounds() async {
    // Get the highest and lowest longitude and latitude
    double minLat = _markers.first.position.latitude;
    double minLong = _markers.first.position.longitude;
    double maxLat = _markers.first.position.latitude;
    double maxLong = _markers.first.position.longitude;

    for (Marker marker in _markers) {
      LatLng pos = marker.position;
      if (pos.latitude < minLat) minLat = pos.latitude;
      if (pos.longitude < minLong) minLong = pos.longitude;
      if (pos.latitude > maxLat) maxLat = pos.latitude;
      if (pos.longitude > maxLong) maxLong = pos.longitude;
    }

    // Calculate center of map
    double centerLat = (minLat + maxLat) / 2;
    double centerLong = (minLong + maxLong) / 2;
    LatLng centerBounds = LatLng(centerLat, centerLong);

    // Initialize Camera Position
    CameraPosition cp = CameraPosition(target: centerBounds, zoom: 13);

    // Move the camera to the position
    _controller.animateCamera(CameraUpdate.newCameraPosition(cp));
  }


  Future<LatLngBounds> _calculateBounds() async {
    LatLng southwest;
    LatLng northeast;
    double swLat = 90;
    double swLng = 180;
    double neLat = -90;
    double neLng = -180;

    for (Marker marker in _markers) {
      LatLng position = marker.position;
      if (position.latitude < swLat) swLat = position.latitude;
      if (position.longitude < swLng) swLng = position.longitude;
      if (position.latitude > neLat) neLat = position.latitude;
      if (position.longitude > neLng) neLng = position.longitude;
    }

    southwest = LatLng(swLat, swLng);
    northeast = LatLng(neLat, neLng);

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  double _calculateDistance(List<LatLng> polylinePoints) {
    double totalDistanceInMeters = 0.0;
    const double earthRadius = 6371; // earth radius in kilometers

    for (int i = 0; i < polylinePoints.length - 1; i++) {
      double lat1 = polylinePoints[i].latitude;
      double lon1 = polylinePoints[i].longitude;
      double lat2 = polylinePoints[i + 1].latitude;
      double lon2 = polylinePoints[i + 1].longitude;

      double dLat = _toRadians(lat2 - lat1);
      double dLon = _toRadians(lon2 - lon1);

      double a = sin(dLat / 2) * sin(dLat / 2) +
          cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
              sin(dLon / 2) * sin(dLon / 2);

      double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      double distance = earthRadius * c;

      totalDistanceInMeters += distance;
    }

    return totalDistanceInMeters;
  }


  Future<List<LatLng>> _getRouteCoordinates(LatLng origin, LatLng destination) async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$API_KEY';

    http.Response response = await http.get(Uri.parse(url));
    Map values = jsonDecode(response.body);

    return _decodeEncodedPolyline(values["routes"][0]["overview_polyline"]["points"]);
  }

  List<LatLng> _decodeEncodedPolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng p = new LatLng(lat / 1E5, lng / 1E5);
      points.add(p);
    }

    return points;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  int _calculateDuration(List<LatLng> polylinePoints) {
    const double AVERAGE_DRIVING_SPEED_KPH = 30;
    double distanceInKilometers = _calculateDistance(polylinePoints);
    int durationInMinutes = (distanceInKilometers / AVERAGE_DRIVING_SPEED_KPH * 60).round();
    return durationInMinutes;
  }



  void _onMapControllerComplete() async {
    await Future.delayed(Duration(milliseconds: 100)); // you can try increasing the delay if needed
    _animateCameraToBounds();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.delayed(Duration(seconds: 1)), // wait for 1 second
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // show loading indicator while waiting
          } else {
            if (_controllerReady) {
              _animateCameraToBounds(); // move camera to bounds
            }

            return Scaffold(
              appBar: AppBar(

                title: Text(
                  'Viaje-Code: ${widget.uniqueCode}',
                  style: TextStyle(color: Colors.white70),
                ),
                backgroundColor: Colors.blue,
                actions: [

                  IconButton(
                    icon: Icon(Icons.account_box, color: Colors.black),
                    onPressed: () {
                      // Handle profile icon press
                    },
                  ),
                ],
              ),

              body: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: GoogleMap(
                        markers: _markers,
                        polylines: _polylines,
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                          _onMapControllerComplete();
                        },
                        initialCameraPosition: CameraPosition(
                          target: LatLng(37.7749, -122.4194),
                          zoom: 13,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Código único: ${widget.uniqueCode}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Distancia: ${_polylines.isNotEmpty ? _calculateDistance(_polylines.first.points).toStringAsFixed(2) + " KM" : "No Data"}',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Duración: ${_polylines.isNotEmpty
                                ? _calculateDuration(_polylines.first.points).toString() + " minutos" : "No Data"}',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        }
    );
  }
}





  class AddedRoute extends StatelessWidget {
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  AddedRoute({required this.markers, required this.polylines});

  @override
  Widget build(BuildContext context) {
    final _markers = markers;
    final _polylines = polylines;

    return Scaffold(
      appBar: AppBar(


        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: Icon(Icons.account_box
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
              // Handle profile icon press
            },
          ),
        ],
        title: Text('Ruta Actualizada'),
      ),
      body: GoogleMap(
        markers: _markers,
        polylines: _polylines,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 20,
        ),
      ),
    );
  }
}
