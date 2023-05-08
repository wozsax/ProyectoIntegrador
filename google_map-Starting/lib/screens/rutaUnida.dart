import 'dart:math';


import 'package:flutter/material.dart';
import 'package:google_mao/screens/perfil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';





class RutaUnida extends StatefulWidget {

  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final String route;
  final String hour;
  final String carModel;

  RutaUnida({required this.markers, required this.polylines, required this.route, required this.hour, required this.carModel});

  @override
  _RutaUnidaState createState() => _RutaUnidaState();
}

class _RutaUnidaState extends State<RutaUnida> {
  final _routeController = TextEditingController();
  final _hourController = TextEditingController();
  final _carModelController = TextEditingController();
  late GoogleMapController _controller;
  bool _controllerReady = false;
  late Set<Marker> _markers;
  late Set<Polyline> _polylines;

  @override
  void initState() {
    _routeController.text = widget.route;
    _hourController.text = widget.hour;
    _carModelController.text = widget.carModel;
    super.initState();
    _markers = widget.markers;
    _polylines = widget.polylines;
    List<LatLng> polylineCoordinates = [];
    for (Marker marker in _markers) {
      polylineCoordinates.add(marker.position);
    }
    _polylines.add(Polyline(
      polylineId: PolylineId('route'),
      color: Colors.blue,
      points: polylineCoordinates,
    ));
  }
  Future<void> _animateCameraToBounds() async {
    if (_controllerReady) {
      LatLngBounds bounds = _calculateBounds();
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
      await _controller.animateCamera(cameraUpdate);
    }
  }


  LatLngBounds _calculateBounds() {
    LatLngBounds bounds;
    LatLng southwest;
    LatLng northeast;
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

    southwest = LatLng(swLat, swLng);
    northeast = LatLng(neLat, neLng);
    bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    return bounds;
  }
  double _calculateDistance(List<LatLng> polylinePoints) {
    const int earthRadius = 6371000; // meters
    double totalDistanceInMeters = 0.0;

    for (int i = 0; i < polylinePoints.length - 1; i++) {
      double lat1 = polylinePoints[i].latitude;
      double lon1 = polylinePoints[i].longitude;
      double lat2 = polylinePoints[i + 1].latitude;
      double lon2 = polylinePoints[i + 1].longitude;

      double dLat = _toRadians(lat2 - lat1);
      double dLon = _toRadians(lon2 - lon1);

      double a = sin(dLat / 2) * sin(dLat / 2) +
          cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
              sin(dLon / 2) *
              sin(dLon / 2);

      double c = 2 * atan2(sqrt(a), sqrt(1 - a));
      double distance = earthRadius * c;

      totalDistanceInMeters += distance;
    }

    double distanceInKm = totalDistanceInMeters / 1000;
    return distanceInKm;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  int _calculateDuration(List<LatLng> polylinePoints) {
    const AVERAGE_DRIVING_SPEED_KPH = 30;
    double distanceInMeters = _calculateDistance(polylinePoints);
    int durationInSeconds = (distanceInMeters / 1000 / AVERAGE_DRIVING_SPEED_KPH * 3600).round();
    return durationInSeconds;
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ruta Unida'),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            onPressed: () {
              // Handle profile icon press
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(10),
              child: GoogleMap(
                markers: _markers,
                polylines: _polylines,
                onMapCreated: (controller) {
                  _controller = controller;
                  setState(() {
                    _controllerReady = true;
                  });
                  _animateCameraToBounds();
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.7749, -122.4194),
                  zoom: 10,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Distancia: ${_polylines.isNotEmpty ? _calculateDistance(_polylines.first.points) : "KM"}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Duración: ${_polylines.isNotEmpty ? _calculateDuration(_polylines.first.points) : "hora"}',

                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}








class AddedRoute extends StatelessWidget {
  final Set<Marker> markers;
  final Set<Polyline> polylines;

  AddedRoute({required this.markers, required this.polylines});

  @override
  Widget build(BuildContext context) {
    final _markers = markers;
    final _polylines = polylines;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          IconButton(
            icon: CircleAvatar(
              backgroundImage: AssetImage('assets/profile.jpg'),
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
              // Handle profile icon press
            },
          ),
        ],
        title: Text('Ruta Actualizada'),
      ),
      body: GoogleMap(
        markers: _markers,
        polylines: _polylines,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 10,
        ),
      ),
    );
  }
}
