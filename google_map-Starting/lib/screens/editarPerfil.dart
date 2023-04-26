import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: EditProfileScreen(),
  ));
}

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _licensePlate = '';
  String _vehicleColor = '';
  String _vehicleModel = '';
  int _spacesAvailable = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'License Plate',
                ),
                onChanged: (value) => _licensePlate = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your license plate';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Vehicle Color',
                ),
                onChanged: (value) => _vehicleColor = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle color';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Vehicle Model',
                ),
                onChanged: (value) => _vehicleModel = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your vehicle model';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Spaces Available',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => _spacesAvailable = int.parse(value),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of spaces available';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile updated')),
                    );
                  }
                },
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

