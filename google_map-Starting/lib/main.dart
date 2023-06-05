import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mao/order_traking_page.dart';
import 'package:google_mao/screens/signin_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'screens/addpage.dart';
import 'package:google_maps_webservice/src/core.dart' as maps;

import '../Models/route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final location = maps.Location(lat: 0.0, lng: 0.0); // Replace with actual coordinates
  final route = RouteModel(
    id: 'route_id',
    startPoint: LatLng(0.0, 0.0),
    startLocationName: 'Start Location',
    driverId: 'driver_id',
    endPoint: LatLng(0.0, 0.0),
    endLocationName: 'End Location',
    time: DateTime.now(),
    waypoints: [], stopLocationName: 'Stop location',
  );

  runApp(MyApp(location: location, route: route));
}



class MyApp extends StatelessWidget {
  final maps.Location location;
  final RouteModel route;

  const MyApp({Key? key, required this.location, required this.route}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: SignInScreen(location: location, route: route),
    );
  }
}
