import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:google_mao/screens/completed_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLngBounds;

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiKey = 'AIzaSyBBpHiAzk7D0ZUtIZvpy2OsSgGGm1eniic';

class PickUpScreen extends StatefulWidget {
  @override
  _PickUpScreen createState() => _PickUpScreen();

}

class _PickUpScreen extends State<PickUpScreen> {
  // ...
  // Keep the other code from before (API key, LatLng, initState, calculateMidpoint, etc.)
  Completer<GoogleMapController> _controller = Completer();
  Set<Polyline> _polylines = Set<Polyline>();
  Set<Marker> _markers = Set<Marker>(); // Add this line
  LatLng _origin = LatLng(37.7749, -122.4194); // Replace with the desired origin LatLng
  LatLng _destination = LatLng(34.0522, -118.2437); // Replace with the desired destination LatLng

  Future<void> _getRoute() async {
    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_origin.latitude},${_origin.longitude}&destination=${_destination.latitude},${_destination.longitude}&key=$apiKey';

    http.Response response = await http.get(Uri.parse(url));
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse['status'] == 'OK') {
      List<LatLng> points = _decodePolyline(
          jsonResponse['routes'][0]['overview_polyline']['points']);
      Polyline polyline = Polyline(
        polylineId: PolylineId('route'),
        color: Colors.blue,
        width: 5,
        points: points,
      );

      setState(() {
        _polylines.add(polyline);
      });

      // Add a red marker at the start
      Marker originMarker = Marker(
        markerId: MarkerId('origin'),
        position: _origin,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      setState(() {
        _markers.add(originMarker);
      });

      // Calculate midpoint and move the green marker
      LatLng midpoint = _calculateMidpoint(_origin, _destination);
      Marker stopMarker = Marker(
        markerId: MarkerId('stop'),
        position: midpoint,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );

      setState(() {
        _markers.add(stopMarker);
      });

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(
          jsonResponse['routes'][0]['bounds']['southwest']['lat'],
          jsonResponse['routes'][0]['bounds']['southwest']['lng'],
        ),
        northeast: LatLng(
          jsonResponse['routes'][0]['bounds']['northeast']['lat'],
          jsonResponse['routes'][0]['bounds']['northeast']['lng'],
        ),
      );

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }



  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
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

      LatLng p = LatLng(lat / 1e5, lng / 1e5);
      points.add(p);
    }

    return points;
  }

  @override
  void initState() {
    super.initState();
    _markers.add(Marker(
      markerId: MarkerId('origin'),
      position: _origin,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    ));
    _markers.add(Marker(
      markerId: MarkerId('destination'),
      position: _destination,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));
    _createPolyline();
    _getRoute();
  }


  LatLng _calculateMidpoint(LatLng point1, LatLng point2) {
    double latitude = (point1.latitude + point2.latitude * 2) / 3;
    double longitude = (point1.longitude + point2.longitude * 2) / 3;
    return LatLng(latitude, longitude);
  }
  void _createPolyline() {
    Polyline polyline = Polyline(
      polylineId: PolylineId('route'),
      color: Colors.blue,
      width: 5,
      points: [_origin, _calculateMidpoint(_origin, _destination), _destination],
    );

    setState(() {
      _polylines.add(polyline);
    });
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viaje 1234'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              // Handle profile icon press
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _calculateMidpoint(_origin, _destination),
                zoom: 6,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },

              markers: _markers,
              polylines: _polylines,
            ),
          ),
      Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Trip Number: 1234',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'From: San Francisco',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'To: Los Angeles',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Duration: 15 mins',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Stops: 3',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Recoge a',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Jose Maria\'Flores',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CompletedScreen()));// Handle 'se unio' button press
                    },
                    child: Text('se unio'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      padding:
                      EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CompletedScreen()));// Handle 'no se unio' button press
                    },
                    child: Text('no se unio'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      padding:
                      EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                      textStyle: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
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
