import 'package:flutter/material.dart';
import 'carbooking_screen.dart';
//import 'notification_screen.dart';

class RouteScreen extends StatefulWidget {
  @override
  _RouteScreenState createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Viajes'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed: () {
              // Handle profile icon press
              // Handle profile icon press
            },
            icon: Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    //MaterialPageRoute(builder: (context) => NotificationScreen()),
                    //location faltante genera error
                    MaterialPageRoute(
                        builder: (context) {
                          return CarBookingScreen();//es necesario ver la api, location es un objeto
                        }),
                  );// Handle 'Crear Ruta' button press
                },
                child: Text('Crear Ruta'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                Icon(
                  Icons.directions_car,
                  size: 50,
                  color: Colors.blue,
                ),
                SizedBox(height: 30),
                Text(
                  'Información del viaje pasado',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                Text(
                  'Desde: Origen',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Hasta: Destino',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 30),
                Text(
                  'Código del viaje: ABC123',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  '3 Lugares Disponibles',
                  style: TextStyle(fontSize: 16),
                ),
                // Add other information about the trip below
              ],
            ),
          ),

        ],
      ),
    );
  }
}
