import 'package:google_maps_flutter/google_maps_flutter.dart';

class PassengerMarker {
  final String id;
  final String routeId;
  final LatLng pickupLocation;

  PassengerMarker({
    required this.id,
    required this.routeId,
    required this.pickupLocation,
  });

  factory PassengerMarker.fromJson(Map<String, dynamic> json) {
    return PassengerMarker(
      id: json['id'] ?? '',
      routeId: json['routeId'] ?? '',
      pickupLocation: LatLng(
        json['pickupLocation']['latitude'] ?? 0.0,
        json['pickupLocation']['longitude'] ?? 0.0,
      ),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'pickupLocation': {
        'latitude': pickupLocation.latitude,
        'longitude': pickupLocation.longitude
      },
    };
  }
}