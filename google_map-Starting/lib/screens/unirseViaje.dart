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
  @override
  State<StatefulWidget> createState() {
    return _UnirseViaje();
  }
}

class _UnirseViaje extends State<UnirseViaje> {
  late GoogleMapController _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  int _markerIdCounter = 0;
  List<LatLng> _polylinePoints = [];

  @override
  void initState() {
    super.initState();

    // Add initial markers
    _markers.add(
      Marker(
        markerId: MarkerId("1"),
        position: LatLng(37.7749, -122.4194),
        infoWindow: InfoWindow(
          title: "Stop 1",
          snippet: "San Francisco, CA",
        ),
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId("2"),
        position: LatLng(37.3363, -121.8904),
        infoWindow: InfoWindow(
          title: "Stop 2",
          snippet: "San Jose, CA",
        ),
      ),
    );

    // Add polyline points for the street route
    _polylinePoints.add(LatLng(37.7749, -122.4194)); // Start location
    _polylinePoints.add(LatLng(37.3363, -121.8904)); // End location
    _updatePolyline();
  }




  void _onMapTapped(LatLng position) async {
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
      _markerIdCounter++;
    });

    if (_polylinePoints.length > 1) {
      String apiUrl = "https://maps.googleapis.com/maps/api/directions/json?origin=${_polylinePoints.first.latitude},${_polylinePoints.first.longitude}&destination=${_polylinePoints.last.latitude},${_polylinePoints.last.longitude}&waypoints=";
      for (int i = 1; i < _polylinePoints.length - 1; i++) {
        apiUrl += "${_polylinePoints[i].latitude},${_polylinePoints[i].longitude}|";
      }
      apiUrl += "&mode=driving&key=AIzaSyBBpHiAzk7D0ZUtIZvpy2OsSgGGm1eniic";

      var response = await http.get(Uri.parse(apiUrl));
      var decoded = jsonDecode(response.body);

      if (decoded['status'] == 'OK') {
        List<LatLng> newPolylinePoints = decodePolyline(decoded['routes'][0]['overview_polyline']['points']);
        _polylinePoints.addAll(newPolylinePoints);
        _updatePolyline();
      } else {
        print('Error getting directions: ${decoded['status']}');
      }
    }
  }

  void _updatePolyline() {
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: _polylinePoints,
          color: Colors.blue,
          width: 3,
          visible: true,
        ),
      );
    });
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
              },
              onTap: _onMapTapped,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              child: Text('Solicitar Parada'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RutaUnida(
                      markers: _markers,
                      polylines: _polylines,
                      route: 'Route Name',
                      hour: '12:00 PM',
                      carModel: 'Car Model',
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
