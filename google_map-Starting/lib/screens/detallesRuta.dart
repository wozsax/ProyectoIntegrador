import 'package:flutter/material.dart';
import 'package:google_mao/screens/perfil.dart';
import 'package:google_mao/screens/unirseViaje.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mao/screens/unirseViaje.dart';

const String apiKey = 'AIzaSyBBpHiAzk7D0ZUtIZvpy2OsSgGGm1eniic';
class DetallesRuta extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DetallesRuta();
  }
}

class _DetallesRuta extends State<DetallesRuta> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
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
    _getDirections();
  }
  Future<void> _getDirections() async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=37.7749,-122.4194&destination=37.3363,-121.8904&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final points = jsonResponse['routes'][0]['overview_polyline']['points'];
      final polylinePoints = PolylinePoints().decodePolyline(points);
      setState(() {
        _polylines.add(
          Polyline(
            polylineId: PolylineId("route1"),
            points: polylinePoints.map((point) => LatLng(point.latitude, point.longitude)).toList(),
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



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
            Expanded(
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
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                child: Text('Unirse al viaje'),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => UnirseViaje()));
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
                        Text('San Francisco, CA'),
                        SizedBox(height: 10),
                        Text('10:00 AM'),
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
                        Text('San Jose, CA'),
                        SizedBox(height: 10),
                        Text('11:30 AM'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
