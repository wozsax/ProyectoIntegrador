import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mao/Models/route.dart';
import 'package:google_mao/Models/user.dart';
import 'package:google_mao/screens/addpage.dart';
import 'package:google_mao/screens/editpage.dart';

import 'package:flutter/material.dart';
import 'package:google_mao/screens/perfil.dart';

import '../Services/route_services.dart';
import '../services/firebase_crud.dart';
import 'detallesRuta.dart';

class RutasDisponibles extends StatefulWidget {
  final RouteModel route;

  RutasDisponibles({required this.route});

  @override
  State<StatefulWidget> createState() {
    return _RutasDisponibles();
  }
}
List<bool> isSelected = [true, false];

class _RutasDisponibles extends State<RutasDisponibles> {
  final RouteService _routeService = RouteService();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rutas Disponibles'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('routes').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<RouteModel> routes = snapshot.data!.docs
                .map((doc) {
              final data = doc.data()! as Map<String, dynamic>;
              data['id'] = doc.id;
              return RouteModel.fromJson(data);
            }).toList().cast<RouteModel>();


            return ListView.builder(
              itemCount: routes.length,
              itemBuilder: (context, index) {
                RouteModel route = routes[index];
                return ListTile(
                  title: Text('Route ID: ${route.id}'),
                  subtitle: Text('${route.startLocationName} a ${route.endLocationName}'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: ()  async {
                    // Navigate to the details screen for this route
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetallesRuta(
                          route: widget.route,
                        ),
                      ),
                    );
                    // Navigate to the details screen for this rout
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}