import 'dart:convert';

import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodingService {
  final String apiKey;

  GeocodingService({required this.apiKey});

  Future<Location> getLocationFromAddress(String address) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      if (results.isNotEmpty) {
        final geometry = results[0]['geometry'];
        final location = geometry['location'];
        final lat = location['lat'];
        final lng = location['lng'];

        return Location(
          latitude: lat,
          longitude: lng,
          timestamp: DateTime.now(),
        );
      } else {
        throw Exception('No results found');
      }
    } else {
      throw Exception('Failed to get location');
    }
  }

  Future<LatLng> getLatLngFromAddress(String address) async {
    final location = await getLocationFromAddress(address);
    return LatLng(location.latitude, location.longitude);
  }
}
