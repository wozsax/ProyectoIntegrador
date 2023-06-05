import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../Models/route.dart';
import 'package:google_mao/screens/unirseViaje.dart';


const String apiKey = 'AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI';

class DetallesRuta extends StatefulWidget {
  final RouteModel route;

  DetallesRuta({required this.route});

  @override
  State<StatefulWidget> createState() {
    return _DetallesRutaState();
  }
}

class _DetallesRutaState extends State<DetallesRuta> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _addMarkers();
    _getDirections();
    print('Start Latitude: ${widget.route.startPoint.latitude}');
    print('Start Longitude: ${widget.route.startPoint.longitude}');
    print('End Latitude: ${widget.route.endPoint.latitude}');
    print('End Longitude: ${widget.route.endPoint.longitude}');
  }

  Future<void> _getDirections() async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${widget
        .route.startPoint.latitude},${widget.route.startPoint
        .longitude}&destination=${widget.route.endPoint.latitude},${widget.route
        .endPoint.longitude}&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final points = jsonResponse['routes'][0]['overview_polyline']['points'];
      final polylinePoints = PolylinePoints().decodePolyline(points);
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId("route1"),
            points: polylinePoints
                .map((point) => LatLng(point.latitude, point.longitude))
                .toList(),
            color: Colors.blue,
            width: 3,
            visible: true,
          ),
        );
      });
    } else {
      print('Error: ${response.statusCode}');
    }
  }

  void _addMarkers() {
    _markers.add(
      Marker(
        markerId: MarkerId("start"),
        position: LatLng(
          widget.route.startPoint.latitude,
          widget.route.startPoint.longitude,
        ),
        infoWindow: InfoWindow(
          title: "Start Location",
          snippet: widget.route.startLocationName,
        ),
      ),
    );

    for (int i = 0; i < widget.route.waypoints.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId('waypoint$i'),
          position: widget.route.waypoints[i],
          infoWindow: InfoWindow(
            title: 'Waypoint $i',
          ),
        ),
      );
    }

    _markers.add(
      Marker(
        markerId: MarkerId("end"),
        position: LatLng(
          widget.route.endPoint.latitude,
          widget.route.endPoint.longitude,
        ),
        infoWindow: InfoWindow(
          title: "End Location",
          snippet: widget.route.endLocationName,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    LatLng startLatLng = widget.route.startPoint; // Updated: Retrieve the start point coordinates
    LatLng endLatLng = widget.route.endPoint; // Updated: Retrieve the end point coordinates

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text("ID: ${widget.route.id}"),
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
          Expanded(
            child: GoogleMap(
              markers: _markers,
              polylines: _polylines,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  startLatLng.latitude, // Updated: Set the camera target to the start point coordinates
                  endLatLng.longitude,
                ),
                zoom: 12,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              child: Text('Unirse al viaje'),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UnirseViaje(route: widget.route, markers: _markers.toList(),)));
                // Code for handling the "Unirse al viaje" button tap goes here
              },
            ),
          ),
          Container(
            height: 150,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  width: 150,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Stop 1'),
                      Text(widget.route.startLocationName),
                      SizedBox(height: 10),
                      Text(widget.route.time.toString()),
                    ],
                  ),
                ),
                Container(
                  width: 150,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Stop 2'),
                      Text(widget.route.endLocationName),
                      SizedBox(height: 10),
                      Text(widget.route.time.toString()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
