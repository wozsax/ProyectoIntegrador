import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/passenger_marker.dart';
import '../Models/route.dart';

class RouteService {
  final CollectionReference _routeCollection =
  FirebaseFirestore.instance.collection('routes');
  final CollectionReference _passengerMarkerCollection =
  FirebaseFirestore.instance.collection('passenger_markers');

  Future<List<RouteModel>> getRoutes() async {
    final querySnapshot = await _routeCollection.get();
    return querySnapshot.docs
        .map((doc) => RouteModel.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> createRoute(RouteModel route) async {
    await _routeCollection.add(route.toJson());
  }

  Future<void> joinRoute(PassengerMarker passengerMarker) async {
    await _passengerMarkerCollection.add(passengerMarker.toJson());
  }
}
