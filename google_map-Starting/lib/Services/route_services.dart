import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/passenger_marker.dart';
import '../Models/route.dart';

class RouteService {
  static final String baseUrl = 'https://projectointegrador-3e7a2-default-rtdb.firebaseio.com';

  final CollectionReference _routeCollection =
  FirebaseFirestore.instance.collection('routes');
  final CollectionReference _passengerMarkerCollection =
  FirebaseFirestore.instance.collection('passenger_markers');

  get http => null;

  Future<List<RouteModel>> getRoutes() async {
    final querySnapshot = await _routeCollection.get();
    return querySnapshot.docs
        .map((doc) => RouteModel.fromJson(doc.id, doc.data()! as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRoute(RouteModel route) async {
    await _routeCollection.add(route.toJson());
  }

  Future<void> joinRoute(PassengerMarker passengerMarker) async {
    await _passengerMarkerCollection.add(passengerMarker.toJson());
  }
  Future<void> updateRoute(RouteModel route) async {
    try {
      // Convert the route object to JSON
      final jsonData = route.toJson();

      // Make an API request to update the route in the database
      final response = await http.put(
        Uri.parse('${RouteService.baseUrl}/routes/${route.id}'),
        body: jsonData,
        headers: {'Content-Type': 'application/json'},
      );

      // Handle the response
      if (response.statusCode == 200) {
        print('Route updated successfully');
      } else {
        print('Failed to update route. Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating route: $error');
    }
  }
}
