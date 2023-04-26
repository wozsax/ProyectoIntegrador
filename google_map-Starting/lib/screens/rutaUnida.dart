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
  late Set<Marker> _markers;
  late Set<Polyline> _polylines;

  @override
  void initState() {
    super.initState();
    _markers = widget.markers;
    _polylines = widget.polylines;
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
                    'Ruta:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    widget.route,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Hora:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    widget.hour,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Modelo de auto:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    widget.carModel,
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