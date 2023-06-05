import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_mao/screens/detallesRuta.dart';
import 'package:google_mao/screens/route_screen.dart';
import 'package:google_mao/screens/rutasDisponobles.dart';
import 'package:google_mao/screens/signin_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/src/core.dart' as maps;
import '../Models/route.dart';



import '../Models/route.dart';

class HomeScreen extends StatefulWidget {
  final maps.Location location;
  final RouteModel route;

  HomeScreen({required this.location, required this.route});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late RouteModel route;

  @override
  void initState() {
    super.initState();
    route = RouteModel(
      id: '',
      startPoint: LatLng(0.0, 0.0),
      startLocationName: '',
      driverId: '',
      endPoint: LatLng(0.0, 0.0),
      endLocationName: '',
      time: DateTime.now(),
      waypoints: [], stopLocationName: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tipo de Cuenta'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RutasDisponibles(route: route)),
                );
              },
              child: Text('Pasajero'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 20.0),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RouteScreen(location: widget.location, route: widget.route,)),
                );
              },
              child: Text('Conductor'),
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
