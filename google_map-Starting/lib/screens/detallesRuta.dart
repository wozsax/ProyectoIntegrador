import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mao/Models/user.dart';
import 'package:google_mao/screens/addpage.dart';
import 'package:google_mao/screens/editpage.dart';


import 'package:flutter/material.dart';

import '../services/firebase_crud.dart';

class DetallesRuta extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _DetallesRuta();
  }
}
List<bool> isSelected = [true, false];

class _DetallesRuta extends State<DetallesRuta> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
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
                  // handle the press
                },
              )
            ],
          ),
          body: ListView(
            children: [
              new Container(
                margin: EdgeInsets.all(1),
                width: 20,
                height: 100,
              ),
              new Container(
                margin: EdgeInsets.all(5),
                width: 80,
                height: 30.0,
                child: Align(

                  alignment: Alignment.topCenter,
                  child:  ListTile(
                    title: Text('Resumen de Viaje'),
                    leading: Icon(Icons.car_crash_rounded),
                    trailing: Row(


                    ),

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
                      },
                        icon: const Icon(Icons.more))
                  ],
                ),
                subtitle: Text('Copilco Salida 18:30'),


              ),
            ],
          ),
        )
    );
  }
}