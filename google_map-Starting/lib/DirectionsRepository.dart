import 'dart:ui';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mao/Services/GeocodingService.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DirectionsRepository {
  final GeocodingService _geocodingService;
  final String apiKey;

  DirectionsRepository({
    required GeocodingService geocodingService,
    required this.apiKey,
  }) : _geocodingService = geocodingService;

  Future<Directions?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final client = http.Client();

    final response = await client.get(
      Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': apiKey,
        },
      ),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final directions = Directions.fromMap(data, origin, destination);
      return directions;
    }
    return null;
  }
}
class DirectionsStep {
  final LatLng start;
  final LatLng end;

  DirectionsStep({required this.start, required this.end});
}
List<LatLng> _decodePoly(String encoded) {
  List<PointLatLng> points =
  PolylinePoints().decodePolyline(encoded).map((e) => PointLatLng(e.latitude, e.longitude)).toList();
  return points.map((point) => LatLng(point.latitude, point.longitude)).toList();
}

class Directions {
  final LatLngBounds? bounds;
  final String points;
  final LatLng startLocation;
  final LatLng endLocation;

  Directions({
    required this.bounds,
    required this.points,
    required this.startLocation,
    required this.endLocation,
  });

  factory Directions.fromMap(Map<String, dynamic> map, LatLng origin, LatLng destination) {
    if ((map['routes'] as List).isEmpty) {
      return Directions(
        bounds: null,
        points: '',
        startLocation: origin,
        endLocation: destination,
      );
    }

    final data = Map<String, dynamic>.from(map['routes'][0]);

    return Directions(
      bounds: LatLngBounds(
        southwest: LatLng(
          data['bounds']['southwest']['lat'],
          data['bounds']['southwest']['lng'],
        ),
        northeast: LatLng(
          data['bounds']['northeast']['lat'],
          data['bounds']['northeast']['lng'],
        ),
      ),
      points: data['overview_polyline']['points'],
      startLocation: LatLng(
        data['legs'][0]['start_location']['lat'],
        data['legs'][0]['start_location']['lng'],
      ),
      endLocation: LatLng(
        data['legs'][0]['end_location']['lat'],
        data['legs'][0]['end_location']['lng'],
      ),
    );
  }
}



