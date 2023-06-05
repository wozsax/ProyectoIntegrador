import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mao/screens/completed_screen.dart';
import 'package:google_mao/screens/rutasDisponobles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import '../DirectionsRepository.dart';
import '../Services/GeocodingService.dart';
import '../Services/route_services.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geocoding_platform_interface/src/models/location.dart';
import 'package:google_maps_webservice/src/core.dart' as maps;
import 'package:google_maps_webservice/places.dart';
import 'package:google_mao/components/network_utility.dart';
import 'package:google_mao/Models/autocomplete_prediction.dart';
import 'package:google_mao/Models/place_auto_complete_response.dart' as ku;
import 'package:google_mao/components/location_list_tile.dart';
import 'package:google_mao/screens/rutasDisponobles.dart';

import 'package:google_mao/Models/route.dart';

import 'detallesRuta.dart';


class CarBookingScreen extends StatefulWidget {
  late RouteModel route = RouteModel(
      id: '',
      startPoint: LatLng(0.0, 0.0),
      startLocationName: '',
      driverId: '',
      endPoint: LatLng(0.0, 0.0),
      endLocationName: '',
      time: DateTime.now(),
      waypoints: [], stopLocationName: '');
  final maps.Location location;

  CarBookingScreen({required this.location});

  @override
  _CarBookingScreenState createState() =>
      _CarBookingScreenState(location: this.location);
}

class _CarBookingScreenState extends State<CarBookingScreen> {

  List<AutocompletePrediction> placePredictions = [];
  final _destinationFocusNode = FocusNode();
  TextEditingController? activeController;
  int index = 0;

  LatLng? startLatLng;
  LatLng? endLatLng;

  Future<void> placeAutocomplete(String query) async {
    final sessionToken = Uuid().v4(); // Generate a unique session token
    final places = GoogleMapsPlaces(apiKey: 'AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI');

    final response = await places.autocomplete(
      query,
      sessionToken: sessionToken,
      language: 'es',
      components: [
        Component(Component.country, 'mx'), // Replace 'mx' with your desired country code
      ],
    );

    if (response.isOkay) {
      setState(() {
        placePredictions = response.predictions.map((prediction) {
          return AutocompletePrediction(
            description: prediction.description,
            placeId: prediction.placeId,
          );
        }).toList();
      });
    } else {
      print('Error occurred while fetching place predictions: ${response.errorMessage}');
    }
  }

  late RouteModel _route;
  final maps.Location location;
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: 'AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI');
  _CarBookingScreenState({required this.location});

  set route(RouteModel value) {
    _route = value;
  }

  @override
  void initState() {
    super.initState();
    route = widget.route;
  }

  bool validateBookingDateTime() {
    DateTime bookingDateTime = selectedDate.add(selectedTime as Duration);
    DateTime now = DateTime.now();

    // Booking date and time must be at least one hour in the future from now
    return bookingDateTime.isAfter(now.add(Duration(hours: 1)));
  }

  Future<String> getStartLocationName(LatLng coordinates) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return '${placemark.thoroughfare} ${placemark.subThoroughfare}, ${placemark.locality}, ${placemark.country}';
    }
    return 'Unknown Location';
  }

  Future<String> getEndLocationName(LatLng coordinates) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return '${placemark.thoroughfare} ${placemark.subThoroughfare}, ${placemark.locality}, ${placemark.country}';
    }
    return 'Unknown Location';
  }

  void _setStartAndEndLocationNames() {
    setState(() {
      startLatLng = LatLng(widget.route.startPoint.latitude, widget.route.startPoint.longitude);
      endLatLng = LatLng(widget.route.endPoint.latitude, widget.route.endPoint.longitude);
    });
  }


  final _formKey = GlobalKey<FormState>();
  String startLocationName = '';
  String endLocationName = '';
  String stopLocationName = '';
  TextEditingController _routeIdController = TextEditingController();
  String userId = ''; // replace with the actual user ID
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 0, minute: 0);
  List<RouteModel> rutasDisponibles = [];
  final repo = DirectionsRepository(
    apiKey: 'AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI',
    geocodingService: GeocodingService(apiKey: 'AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI'),
  );
  String? _startAddress;
  String? _destinationAddress;
  DateTime? _selectedEndDate;

  String get _formattedStartDate =>
      _selectedDate == null ? 'Pick a date' : DateFormat.yMd().add_jm().format(_selectedDate!);

  String get _formattedEndDate =>
      _selectedEndDate == null ? 'Pick a date' : DateFormat.yMd().add_jm().format(_selectedEndDate!);

  String get _formattedStartLocation => _startAddress ?? 'Select pickup location';

  String get _formattedEndLocation => _destinationAddress ?? 'Select destination';

  final _originController = TextEditingController();
  final _destinationController = TextEditingController();
  final RouteService _routeService = RouteService();
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && _selectedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> saveRoute() async {
    if (_selectedDate == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please select a date and time.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final origin = _originController.text;
    final destination = _destinationController.text;
    final geocodingService = GeocodingService(apiKey: "AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI");

    final startLocation = await geocodingService.getLatLngFromAddress(origin);
    final endLocation = await geocodingService.getLatLngFromAddress(destination);

    if (startLocation == null || endLocation == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Invalid start or end location.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    startLatLng = LatLng(startLocation.latitude, startLocation.longitude);
    endLatLng = LatLng(endLocation.latitude, endLocation.longitude);

    _setStartAndEndLocationNames();

    RouteModel newRoute = RouteModel(
      id: _routeIdController.text,
      driverId: userId,
      startPoint: startLatLng!,
      endPoint: endLatLng!,
      time: selectedDate.add(Duration(hours: selectedTime.hour, minutes: selectedTime.minute)),
      waypoints: [],
      startLocationName: startLocationName,
      endLocationName: endLocationName,
      stopLocationName: stopLocationName,
    );


    await FirebaseFirestore.instance.collection('routes').add(newRoute.toJson());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text('Route saved successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    _destinationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Ruta'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.car_rental, size: 100),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _originController,
                        onTap: () {
                          activeController = _originController;
                        },
                        onChanged: (value) {
                          placeAutocomplete(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Origen',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _destinationController,
                        onTap: () {
                          activeController = _destinationController;
                        },
                        onChanged: (value) {
                          placeAutocomplete(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Destino',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Date and Time'),
            subtitle: _selectedDate != null
                ? Text(DateFormat.yMMMd().add_jm().format(_selectedDate!))
                : null,
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () async {
              setState(() {
                activeController!.text = placePredictions[index].description!;
              });

              final places = GoogleMapsPlaces(apiKey: 'AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI');
              final response = await places.getDetailsByPlaceId(placePredictions[index].placeId!);


              if (response.status == 'OK') {
                final result = response.result;
                final geometry = result.geometry;
                final location = geometry!.location;

                setState(() {
                  startLatLng = LatLng(location.lat, location.lng);
                  endLatLng = LatLng(location.lat, location.lng);
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetallesRuta(
                      route: RouteModel(
                        id: widget.route.id,
                        startPoint: widget.route.startPoint,
                        endPoint: widget.route.endPoint,
                        startLocationName: placePredictions[index].description!,
                        endLocationName: placePredictions[index].description!,
                        stopLocationName: '', driverId: '', time: DateTime.now(), waypoints: [],
                      ),
                    ),
                  ),
                );
              } else {
                print('Error occurred while fetching place details: ${response.errorMessage}');
              }
            },




          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () async {
                  final origin = _originController.text;
                  final destination = _destinationController.text;
                  final geocodingService = GeocodingService(apiKey: "AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI");

                  final originLatLng = await geocodingService.getLatLngFromAddress(origin);
                  final destinationLatLng = await geocodingService.getLatLngFromAddress(destination);
                  startLatLng = LatLng(originLatLng.latitude, originLatLng.longitude);
                  endLatLng = LatLng(destinationLatLng.latitude, destinationLatLng.longitude);

                  _setStartAndEndLocationNames();

                  RouteModel newRoute = RouteModel(
                    id: _routeIdController.text,
                    driverId: userId,
                    startPoint: LatLng(originLatLng.latitude, originLatLng.longitude),
                    endPoint: LatLng(destinationLatLng.latitude, destinationLatLng.longitude),

                    time: selectedDate.add(Duration(hours: selectedTime.hour, minutes: selectedTime.minute)),
                    waypoints: [],
                    startLocationName: startLocationName,
                    endLocationName: endLocationName,
                    stopLocationName: stopLocationName,
                  );

                  final DocumentReference result = await FirebaseFirestore.instance.collection('routes').add(newRoute.toJson());

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RutasDisponibles(route: newRoute)),
                  );
                },
                child: Text('Crear'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),

            ),
          ),
          const Divider(
            height: 4,
            thickness: 4,
            color: Colors.cyan,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: placePredictions.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(placePredictions[index].description!),
                onTap: () {
                  setState(() {
                    activeController!.text = placePredictions[index].description!;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}