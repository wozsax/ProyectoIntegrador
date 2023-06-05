import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_mao/screens/perfil.dart';
import 'package:google_mao/screens/rutaUnida.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:uuid/uuid.dart';

import '../Models/route.dart';
import '../Services/route_services.dart';



List<LatLng> decodePolyline(String encoded) {
  List<LatLng> poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;
  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5), (lng / 1E5));
    poly.add(p);
  }
  return poly;
}

class UnirseViaje extends StatefulWidget {
  final RouteModel route;
  final List<Marker> markers;

  UnirseViaje({required this.markers, required this.route});

  @override
  State<StatefulWidget> createState() {
    return _UnirseViajeState();
  }
}

class _UnirseViajeState extends State<UnirseViaje> {
  late String routeId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _destinationController = TextEditingController();
  List<Map<String, double>> _waypoints = [];

  Marker? _selectedMarker;
  Set<Marker> _markers = {};
  final places =
  GoogleMapsPlaces(apiKey: 'AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI');
  bool _isMapReady = false;
  late GoogleMapController _controller;
  bool _controllerReady = false;

  Set<Polyline> _polylines = {};
  int _markerIdCounter = 0;
  List<LatLng> _polylinePoints = [];


  void _updateRoute() async {
    final String routeId = Uuid().v4();

    // Create a new list of waypoints including the new stop
    List<LatLng> updatedWaypoints = _markers.map((marker) => marker.position).toList();

    // Get the start and end points of the route
    LatLng startPoint = updatedWaypoints.first;
    LatLng endPoint = updatedWaypoints.last;

    // Get the start and end location names
    String stopLocationName = _destinationController.text; // Assuming the destination field is the stop location
    String endLocationName = widget.route.endLocationName; // Assuming the end location name is fixed
    String startLocationName = widget.route.startLocationName;
    // Create a new instance of RouteModel with the updated information
    final updatedRoute = RouteModel(
      id: routeId,
      driverId: 'your_driver_id',
      startPoint: startPoint,
      endPoint: endPoint,
      stopLocationName: stopLocationName,
      startLocationName: startLocationName,
      endLocationName: endLocationName,
      time: DateTime.now(),
      waypoints: updatedWaypoints,
    );
    await RouteService().updateRoute(updatedRoute);
    saveStopLocation(routeId, stopLocationName);
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;




    await RouteService().updateRoute(updatedRoute);

    // Show a success message or perform any other necessary actions
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Route updated successfully')),
    );
  }
  Future<void> saveStopLocation(String routeId, String stopLocationName) async {
    print('routeId: $routeId, stopLocation: $stopLocationName');  // Add this line
    await _firestore.collection('routes').doc(routeId).set(
      {
        'stopLocationName': stopLocationName,
      },
      SetOptions(merge: true),
    );
  }






  void _placeMarker(LatLng position) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('marker_${_markerIdCounter++}'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Stop ${_markerIdCounter}',
            snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
          ),
        ),
      );

      if (_isMapReady) {
        _animateCameraToBounds();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    // Add initial markers
    _markers = widget.markers.toSet();
    _polylinePoints = _markers.map((marker) => marker.position).toList();
    _polylines = {
      Polyline(
        polylineId: PolylineId('route'),
        points: _polylinePoints,
        color: Colors.blue,
        width: 3,
        visible: true,
      ),
    };

    // Initialize the polylines set with a default Polyline if there are any markers.
    if (_markers.isNotEmpty) {
      _polylines = {
        Polyline(
          polylineId: PolylineId('route'),
          points: _polylinePoints,
          color: Colors.blue,
          width: 3,
          visible: true,
        ),
      };
    }
  }

  LatLngBounds _calculateBounds() {
    double swLat = 90;
    double swLng = 180;
    double neLat = -90;
    double neLng = -180;

    for (Marker marker in _markers) {
      LatLng position = marker.position;
      if (position.latitude < swLat) swLat = position.latitude;
      if (position.longitude < swLng) swLng = position.longitude;
      if (position.latitude > neLat) neLat = position.latitude;
      if (position.longitude > neLng) neLng = position.longitude;
    }

    LatLng southwest = LatLng(swLat, swLng);
    LatLng northeast = LatLng(neLat, neLng);

    return LatLngBounds(southwest: southwest, northeast: northeast);
  }

  Future<void> _animateCameraToBounds() async {
    if (_controllerReady && _markers.isNotEmpty) {
      LatLngBounds bounds = _calculateBounds();
      await _controller.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50)); // 50 is the padding. Adjust this as needed.
    }
  }

  void _onMapTapped(LatLng position) async {
    setState(() {
      _addMarker(position);
    });
  }

  void _addMarker(LatLng position) async {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('marker_${_markerIdCounter++}'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Stop ${_markerIdCounter}',
            snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
          ),
        ),
      );

      if (_isMapReady) {
        _animateCameraToBounds();
      }

      if (_markers.length >= 2) {
        _polylinePoints = _markers.map((marker) => marker.position).toList();
        _updatePolyline();
      }
    });
  }

  void _updatePolyline() {
    setState(() {
      _polylines.clear();
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: _polylinePoints,
          color: Colors.blue,
          width: 3,
          visible: true,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text("Viaje de Liliana"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: Text(
              "Resumen del Viaje",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _destinationController,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Direccion de la parada',
                ),
              ),
              suggestionsCallback: (pattern) async {
                if (pattern.isNotEmpty) {
                  final response = await places.autocomplete(pattern);

                  final suggestions =
                  response.predictions.map((p) => p.description).toList();
                  return suggestions;
                }
                return [];
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  title: Text(suggestion as String),
                );
              },
              onSuggestionSelected: (suggestion) async {
                String selectedSuggestion = suggestion as String;
                _destinationController.text = selectedSuggestion;

                PlacesSearchResponse response =
                await places.searchByText(selectedSuggestion);
                if (response.status == "OK" && response.results.isNotEmpty) {
                  PlacesSearchResult result = response.results[0];
                  double lat = result.geometry?.location.lat ?? 0.0;
                  double lng = result.geometry?.location.lng ?? 0.0;
                  LatLng selectedLocation = LatLng(lat, lng);

                  setState(() {
                    _addMarker(selectedLocation);
                    _selectedMarker = _markers.last;
                    _polylinePoints =
                        _markers.map((marker) => marker.position).toList();
                  });

                  _animateCameraToBounds();

                  // Save the stop location to Firestore
                  await saveStopLocation(routeId, selectedSuggestion);
                }
              },


            ),
          ),
          Expanded(
            child: GoogleMap(
              markers: _markers,
              polylines: _polylines,
              initialCameraPosition: _calculateCameraPosition(),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                _controllerReady = true;
                _animateCameraToBounds();
              },
              onTap: _onMapTapped,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: ElevatedButton(
              child: Text('Unirse al viaje'),
              onPressed: () {



                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RutaUnida(
                      markers: _markers.toSet(),
                      polylines: _polylines,
                      route: '',
                      hour: '',
                      carModel: '',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  LatLng _calculateCenter(LatLngBounds bounds) {
    double lat = (bounds.southwest.latitude + bounds.northeast.latitude) / 2;
    double lng = (bounds.southwest.longitude + bounds.northeast.longitude) / 2;
    return LatLng(lat, lng);
  }

  CameraPosition _calculateCameraPosition() {
    if (_markers.isNotEmpty) {
      LatLngBounds bounds = _calculateBounds();
      LatLng center = _calculateCenter(bounds);
      return CameraPosition(target: center, zoom: 10);
    } else {
      return CameraPosition(target: LatLng(37.7749, -122.4194), zoom: 10);
    }
  }
}