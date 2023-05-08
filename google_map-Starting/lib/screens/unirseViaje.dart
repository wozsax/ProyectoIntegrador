import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mao/screens/perfil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mao/screens/rutaUnida.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';



void main() {
  runApp(MaterialApp(home: UnirseViaje()));
}

List<LatLng> decodePolyline(String encoded) {
  List<LatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;
  while (index < len) {
    int b, shift = 0, result = 0;
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
    LatLng p = LatLng((lat / 1E5), (lng / 1E5));
    poly.add(p);
  }
  return poly;
}

class UnirseViaje extends StatefulWidget {
  final Set<Marker> markers;
  UnirseViaje({this.markers = const <Marker> {}});
  @override
  State<StatefulWidget> createState() {
    return _UnirseViaje();
  }
}

class _UnirseViaje extends State<UnirseViaje> {
  bool _isMapReady = false;
  late GoogleMapController _controller;
  bool _controllerReady = false;

  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  int _markerIdCounter = 0;
  List<LatLng> _polylinePoints = [];



  @override
  void initState() {
    super.initState();
    // Add initial markers
    _markers = Set<Marker>.from(widget.markers);
    _markers.addAll(widget.markers);
    _polylines = {};
    _polylines.add(
      Polyline(
        polylineId: PolylineId('route'),
        points: _polylinePoints,
        color: Colors.blue,
        width: 3,
        visible: true,
      ),
    );


  }
  LatLngBounds _calculateBounds() {
    LatLngBounds bounds;
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
    bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    return bounds;
  }
  Future<void> _animateCameraToBounds() async {
    if (_controllerReady) {
      LatLngBounds bounds = _calculateBounds();
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
      await _controller.animateCamera(cameraUpdate);
    }
  }




  void _onMapTapped(LatLng position) async {
    if (_markers.length >= 5) {
      // If there are already two markers, remove the previous markers and polyline points
      setState(() {
        _markers.clear();
        _polylinePoints.clear();
      });
      _polylines.clear();
    }

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('marker_${_markerIdCounter}'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Stop ${_markerIdCounter + 1}',
            snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
          ),
        ),
      );
      _polylinePoints.add(position);
      _markerIdCounter = (_markerIdCounter + 1) % 2;

      if (_isMapReady) {
        _animateCameraToBounds();
      }
    });

    if (_markers.length == 2) {
      String apiUrl =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${_polylinePoints[0].latitude},${_polylinePoints[0].longitude}&destination=${_polylinePoints[1].latitude},${_polylinePoints[1].longitude}&mode=driving&key=AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI";

      var response = await http.get(Uri.parse(apiUrl));
      var decoded = jsonDecode(response.body);

      if (decoded['status'] == 'OK') {
        List<LatLng> newPolylinePoints = decodePolyline(decoded['routes'][0]['overview_polyline']['points']);
        setState(() {
          _polylinePoints = newPolylinePoints;
          _updatePolyline();
          _animateCameraToBounds();
        });
      } else {
        print('Error getting directions: ${decoded['status']}');
      }
    }
  }


  void _updatePolyline() {
    if (_polylinePoints.length >= 5) {
      _polylines.add( // Add the new polyline to the set of polylines
        Polyline(
          polylineId: PolylineId('route'),
          points: _polylinePoints,
          color: Colors.blue,
          width: 3,
          visible: true,
        ),
      );
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text("Viaje de Liliana"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
              // handle the press
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              "Resumen del Viaje",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.6,
            child: GoogleMap(
              markers: _markers,
              polylines: _polylines,
              initialCameraPosition: CameraPosition(
                target: LatLng(37.7749, -122.4194),
                zoom: 10,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;

                setState(() {
                  _controllerReady = true;
                });
                _animateCameraToBounds();

              },
              onTap: _onMapTapped,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              child: Text('Unirse al viaje'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RutaUnida(
                      markers: _markers, polylines: Set<Polyline>(), route: '', hour: '', carModel: '',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
