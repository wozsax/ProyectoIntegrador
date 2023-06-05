import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteModel {

  final String id;
  final String driverId;
  final LatLng startPoint;
  final LatLng endPoint;
  final String stopLocationName;
  final String startLocationName; // Add start location name
  final String endLocationName; // Add end location name
  final DateTime time;
  final List<LatLng> waypoints;

  RouteModel({
    required this.stopLocationName,
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
    var list = json['waypoints'] as List?;
    List<LatLng> waypointList = list != null
        ? list.map((i) => LatLng(i['latitude'] ?? 0.0, i['longitude'] ?? 0.0)).toList()
        : [];

    double startPointLatitude = (json['startPoint']['latitude'] ?? 0.0).toDouble();
    double startPointLongitude = (json['startPoint']['longitude'] ?? 0.0).toDouble();
    LatLng startPointJson = LatLng(startPointLatitude, startPointLongitude);

    double endPointLatitude = (json['endPoint']['latitude'] ?? 0.0).toDouble();
    double endPointLongitude = (json['endPoint']['longitude'] ?? 0.0).toDouble();
    LatLng endPointJson = LatLng(endPointLatitude, endPointLongitude);

    DateTime time;
    if (json['time'] is int) {
      time = DateTime.fromMillisecondsSinceEpoch(json['time']);
    } else if (json['time'] is String) {
      time = DateTime.parse(json['time']);
    } else {
      throw Exception('Invalid format for time field');
    }

    return RouteModel(
      id: json['id'] ?? '',
      driverId: json['driverId'] ?? '',
      startPoint: startPointJson,
      endPoint: endPointJson,
      startLocationName: json['startLocationName'] ?? '',
      endLocationName: json['endLocationName'] ?? '',
      time: time,
      waypoints: waypointList,
      stopLocationName: json['stopLocationName'] ?? '',
    );
  }



  Map<String, dynamic> toJson() => {
    'id': id,
    'driverId': driverId,
    'startPoint': {
      'lat': startPoint.latitude,
      'lng': startPoint.longitude,
    },
    'endPoint': {
      'lat': endPoint.latitude,
      'lng': endPoint.longitude,
    },
    'startLocationName': startLocationName,
    'endLocationName': endLocationName,
    'time': time.toIso8601String(),
    'waypoints': waypoints.map((point) => {
      'lat': point.latitude,
      'lng': point.longitude,
    }).toList(),
    'stopLocationName': stopLocationName,
  };

  RouteModel copyWith({
    String? id,
    String? driverId,
    LatLng? startPoint,
    LatLng? endPoint,
    String? startLocationName,
    String? endLocationName,
    DateTime? time,
    List<LatLng>? waypoints,
    String? stopLocationName,
  }) {
    return RouteModel(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      startLocationName: startLocationName ?? this.startLocationName,
      endLocationName: endLocationName ?? this.endLocationName,
      time: time ?? this.time,
      waypoints: waypoints ?? this.waypoints,
      stopLocationName: stopLocationName ?? this.stopLocationName,
    );
  }
}
