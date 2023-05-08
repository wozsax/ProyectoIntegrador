import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {
  final String id;
  final String driverId;
  final LatLng startPoint;
  final LatLng endPoint;
  final String startLocationName; // Add start location name
  final String endLocationName; // Add end location name
  final DateTime time;
  final List<LatLng> waypoints;

  RouteModel({
    required this.id,
    required this.driverId,
    required this.startPoint,
    required this.endPoint,
    required this.startLocationName, // Include start location name in constructor
    required this.endLocationName, // Include end location name in constructor
    required this.time,
    required this.waypoints,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'] ?? '',
      driverId: json['driverId'] ?? '',
      startPoint: LatLng(
        json['startPoint']['latitude'] ?? 0.0,
        json['startPoint']['longitude'] ?? 0.0,
      ),
      endPoint: LatLng(
        json['endPoint']['latitude'] ?? 0.0,
        json['endPoint']['longitude'] ?? 0.0,
      ),
      startLocationName: json['startLocationName'] ?? '', // Parse start location name
      endLocationName: json['endLocationName'] ?? '', // Parse end location name
      time: DateTime.fromMillisecondsSinceEpoch(json['time'] ?? 0),
      waypoints: (json['waypoints'] as List)
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'startPoint': {
        'latitude': startPoint.latitude,
        'longitude': startPoint.longitude
      },
      'endPoint': {
        'latitude': endPoint.latitude,
        'longitude': endPoint.longitude
      },
      'startLocationName': startLocationName, // Serialize start location name
      'endLocationName': endLocationName, // Serialize end location name
      'time': time.millisecondsSinceEpoch,
      'waypoints': waypoints.map((point) =>
      {
        'latitude': point.latitude,
        'longitude': point.longitude
      }).toList(),
    };
  }
}
