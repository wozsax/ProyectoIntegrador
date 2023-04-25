import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mao/Models/user.dart';
import 'package:google_mao/screens/addpage.dart';
import 'package:google_mao/screens/editpage.dart';

import 'package:flutter/material.dart';

import '../services/firebase_crud.dart';
import 'detallesRuta.dart';

class RutasDisponibles extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RutasDisponibles();
  }
}
List<bool> isSelected = [true, false];

class _RutasDisponibles extends State<RutasDisponibles> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Rutas Disponibles"),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: 'Perfil',
              onPressed: () {
                // handle the press
              },
            )
          ],
        ),

        body: ListView(
          children: [
            new Container(
              margin: EdgeInsets.all(5),
              width: 80,
              height: 30.0,
              child: Align(
                alignment: Alignment.topLeft,
                child:  ToggleButtons(
                  isSelected: isSelected,
                  onPressed: (int index) {
                    setState(() {
                      for (int buttonIndex = 0; buttonIndex < isSelected.length; buttonIndex++) {
                        if (buttonIndex == index) {
                          isSelected[buttonIndex] = true;
                        } else {
                          isSelected[buttonIndex] = false;
                        }
                      }

                    });
                  },
                  children: const <Widget>[
                    Text('Inicio'),
                    Text('Destino'),

                  ],
                ),

              ),
            ),

            new Container(
              margin: EdgeInsets.all(5),
              width: 80,
              height: 30.0,
              child: Align(
                alignment: Alignment.topRight,
                child:  ElevatedButton(
                  child: Text('Agregar Ruta'),
                  onPressed: () {},
                ),

              ),
            ),

            ListTile(
              leading: Icon(Icons.car_rental),
              title: Text('T-29x45'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => DetallesRuta()));
                  }, icon: const Icon(Icons.more))
                ],
              ),
              subtitle: Text('Copilco Salida 18:30'),


            ),
            ListTile(
                leading: Icon(Icons.car_rental),
                title: Text('T-29x45'),
                 trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.more))
                ],
              ),
              subtitle: Text('Copilco'),
            ),
            ListTile(
                leading: Icon(Icons.car_rental),
                title: Text('T-29x45'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.more))
                ],
              ),
              subtitle: Text('Copilco'),

            ),
          ],
        ),
      )
    );
  }
}
