import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Models/passenger_marker.dart';
import '../Models/route.dart';
import 'package:http/http.dart' as http;

// Initialize the http object
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PassengerMarker {
  final String passengerId;
  final LatLng location;

  PassengerMarker({required this.passengerId, required this.location});

  Map<String, dynamic> toJson() => {
    'passengerId': passengerId,
    'location': {
      'lat': location.latitude,
      'lng': location.longitude,
    },
  };

  factory PassengerMarker.fromJson(Map<String, dynamic> json) {
    return PassengerMarker(
      passengerId: json['passengerId'] ?? '',
      location: LatLng(
        json['location']['lat'] ?? 0.0,
        json['location']['lng'] ?? 0.0,
      ),
    );
  }
}

class RouteService {
  final String apiUrl = 'https://projectointegrador-3e7a2-default-rtdb.firebaseio.com/';
  static final String baseUrl = 'https://projectointegrador-3e7a2-default-rtdb.firebaseio.com/';

  final CollectionReference _routeCollection = FirebaseFirestore.instance.collection('routes');
  final CollectionReference _passengerMarkerCollection = FirebaseFirestore.instance.collection('passenger_markers');

  final http.Client httpClient = http.Client();


  Future<List<RouteModel>> getAllRoutes() async {
    QuerySnapshot querySnapshot = await _routeCollection.get();
    return querySnapshot.docs
        .map((doc) {
      final data = doc.data()! as Map<String, dynamic>;
      data['id'] = doc.id;
      return RouteModel.fromJson(data);
    }).toList().cast<RouteModel>();
  }



  Future<void> createRoute(RouteModel route) async {
    await _routeCollection.doc(route.id).set(route.toJson());
  }





  Future<void> joinRoute(PassengerMarker passengerMarker) async {
    try {
      // Add your logic to update the markers in the database
      // based on the `passengerMarker` object

      // For example, you can access the necessary information from `passengerMarker`
      String passengerId = passengerMarker.passengerId;
      LatLng passengerLocation = passengerMarker.location;

      // Update the corresponding document in the database using Firestore
      await _passengerMarkerCollection.doc(passengerId).update({
        'location': {
          'lat': passengerLocation.latitude,
          'lng': passengerLocation.longitude,
        },
      });

      print('Markers updated successfully');
    } catch (error) {
      print('Error updating markers: $error');
    }
  }
  Future<void> updateRoute(RouteModel route) async {
    try {
      final response = await http.patch(
        Uri.parse(apiUrl + 'routes/${route.id}.json'), // Modify the URL to include the route ID
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(route.toJson()),
      );
      if (response.statusCode == 200) {
        print('Route updated successfully via API');
      } else {
        throw Exception('Failed to update route via API. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to update route via API: $error');
      throw error;
    }
  }

}