import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_mao/screens/aboutus_screen.dart';
import 'package:google_mao/screens/rutasDisponobles.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../DirectionsRepository.dart';
import '../Services/GeocodingService.dart';
import '../Services/route_services.dart';
import '../Models/route.dart';

class CarBookingScreen extends StatefulWidget {
  late RouteModel route =  RouteModel(id: '', startPoint: LatLng(0.0, 0.0), startLocationName: '', driverId: '', endPoint: LatLng(0.0, 0.0), endLocationName: '', time: DateTime.now(), waypoints: []);

  @override
  _CarBookingScreenState createState() => _CarBookingScreenState();
}

class _CarBookingScreenState extends State<CarBookingScreen> {
  late RouteModel _route;

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
    List<Placemark> placemarks =
    await placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return '${placemark.thoroughfare} ${placemark.subThoroughfare}, ${placemark.locality}, ${placemark.country}';
    }
    return 'Unknown Location';
  }

  Future<String> getEndLocationName(LatLng coordinates) async {
    List<Placemark> placemarks =
    await placemarkFromCoordinates(coordinates.latitude, coordinates.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      return '${placemark.thoroughfare} ${placemark.subThoroughfare}, ${placemark.locality}, ${placemark.country}';
    }
    return 'Unknown Location';
  }

  void _setStartAndEndLocationNames() async {
    startLocationName = await getStartLocationName(startLatLng);
    endLocationName = await getEndLocationName(endLatLng);
  }
  final _formKey = GlobalKey<FormState>();
  String startLocationName = '';
  String endLocationName = '';

  TextEditingController _routeIdController = TextEditingController();
  String userId = ''; // replace with the actual user ID
  LatLng startLatLng = LatLng(0, 0); // replace with the actual start coordinates
  LatLng endLatLng = LatLng(0, 0); // replace with the actual end coordinates
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 0, minute: 0);
  List<RouteModel> rutasDisponibles = [];
   // replace with the actual end location name
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
        builder: (context) =>
            AlertDialog(
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
    final geocodingService = GeocodingService(
        apiKey: "AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI");

    final originLatLng = await geocodingService.getLatLngFromAddress(origin);
    final destinationLatLng = await geocodingService.getLatLngFromAddress(
        destination);
    Future<void> _submitRoute() async {
      if (_formKey.currentState?.validate() ?? false){
        _formKey.currentState?.save();
        _setStartAndEndLocationNames();

        bool isValidBookingDateTime = validateBookingDateTime();
        if (isValidBookingDateTime){


        }

        RouteModel newRoute = RouteModel(
          id: _routeIdController.text,
          driverId: userId,
          startPoint: LatLng(startLatLng.latitude, startLatLng.longitude),
          endPoint: LatLng(endLatLng.latitude, endLatLng.longitude),
          time: selectedDate.add(
              Duration(hours: selectedTime.hour, minutes: selectedTime.minute)),

          waypoints: [],
          startLocationName: startLocationName,
          // Add the start location name
          endLocationName: endLocationName, // Add the end location name
        );

        await _routeService.createRoute(newRoute);

      }
      // Call the method to set start and end location names

    }
  }




  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
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
                        decoration: InputDecoration(
                          hintText: 'Origen',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _destinationController,
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
              await _selectDate(context);
              if (_selectedDate != null) {
                await _selectTime(context);
              }
            },
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.all(16),
              child:ElevatedButton(
                onPressed: () async {
                  final origin = _originController.text;
                  final destination = _destinationController.text;
                  final geocodingService = GeocodingService(apiKey: "AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI");

                  final originLatLng = await geocodingService.getLatLngFromAddress(origin);
                  final destinationLatLng = await geocodingService.getLatLngFromAddress(destination);
                  startLatLng = LatLng(originLatLng.latitude, originLatLng.longitude);
                  endLatLng = LatLng(destinationLatLng.latitude, destinationLatLng.longitude);


                  _setStartAndEndLocationNames();
                  double destinationLatitude = destinationLatLng.latitude;
                  double destinationLongitude = destinationLatLng.longitude;
                  final directionsRepository = DirectionsRepository(
                    geocodingService: geocodingService,
                    apiKey: "AIzaSyAhw5o-zrk6aCihBJMU5hUeQrPn-lUyPhI",
                  );
                  final directions = await directionsRepository.getDirections(
                    origin: originLatLng,
                    destination: destinationLatLng,
                  );
                  if (directions?.bounds == null) {
                    throw Exception('No route found');
                  }
                  try {
                    final directions = await directionsRepository.getDirections(
                      origin: originLatLng,
                      destination: destinationLatLng,
                    );

                    // The rest of your code to process the directions

                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text(e.toString()),
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



                  final _originLatitude = directions?.startLocation?.latitude ?? 0.0;
                  final _originLongitude = directions?.startLocation?.longitude ?? 0.0;
                  final _destinationLatitude = directions?.endLocation?.latitude ?? 0.0;
                  final _destinationLongitude = directions?.endLocation?.longitude ?? 0.0;


                  RouteModel newRoute = RouteModel(
                    id: _routeIdController.text,
                    driverId: userId,
                    startPoint: LatLng(startLatLng.latitude, startLatLng.longitude),
                    endPoint: LatLng(endLatLng.latitude, endLatLng.longitude),
                    time: selectedDate.add(Duration(hours: selectedTime.hour, minutes: selectedTime.minute)),

                    waypoints: [],
                    startLocationName: startLocationName, // Add the start location name
                    endLocationName: endLocationName, // Add the end location name
                  );
                  await FirebaseFirestore.instance
                      .collection('routes')
                      .add(newRoute.toJson());

                  await saveRoute();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RutasDisponibles(route: widget.route),
                    ),
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
        ],
      ),
    );
  }
}
