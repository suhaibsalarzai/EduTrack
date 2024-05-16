import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class BusDetailsForm extends StatefulWidget {
  @override
  _BusDetailsFormState createState() => _BusDetailsFormState();
}

class _BusDetailsFormState extends State<BusDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _busDetails = BusDetails();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateRandomPassword(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
          (_) => characters.codeUnitAt(rnd.nextInt(characters.length)),
    ));
  }

  Future<void> addBus(BusDetails busDetails) async {
    try {
      // Convert vehicleNumber to uppercase for case-insensitive comparison
      String vehicleNumberUpperCase = busDetails.vehicleNumber!.toUpperCase();

      // Check for existing bus with the same vehicleNumber in uppercase
      QuerySnapshot querySnapshot = await _firestore
          .collection('buses')
          .where('vehicleNumber', isEqualTo: vehicleNumberUpperCase)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If a bus with the same vehicleNumber already exists, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bus with this Vehicle Number already exists')),
        );
      } else {
        // If no duplicate found, proceed to add the new bus
        await _firestore.collection('buses').add({
          'vehicleNumber': vehicleNumberUpperCase,
'role':'Driver',
          'driverName': busDetails.driverName,
          'driverPhone': busDetails.driverPhone,
          'driverCNIC': busDetails.driverCNIC,
          'driverPassword': busDetails.driverPassword,
          'timeSlot': busDetails.timeSlot,
        });

        // Reset the form fields
        _formKey.currentState?.reset();

        // Show Snackbar message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bus added successfully')),
        );
      }
    } catch (e) {
      throw Exception('Failed to add bus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Bus Details")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Vehicle Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _busDetails.vehicleNumber = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Driver Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter driver name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _busDetails.driverName = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Driver Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^\d{11}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _busDetails.driverPhone = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Driver CNIC'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter driver CNIC';
                  }
                  return null;
                },
                onSaved: (value) {
                  _busDetails.driverCNIC = value!;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Schedule Time Slot"),
                value: _busDetails.timeSlot,
                onChanged: (newValue) {
                  setState(() {
                    _busDetails.timeSlot = newValue;
                  });
                },
                items: <String>['Morning 6-9', 'Afternoon 1-4']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a time slot' : null,
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState!.save();
                    // Generate a random password for the driver
                    _busDetails.driverPassword = generateRandomPassword(5);
                    // Add the bus details
                    addBus(_busDetails);
                  }
                },
                child: Text('Add Bus'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BusDetails {
  String? vehicleNumber;
  String? driverName;
  String? driverPhone;
  String? driverCNIC;
  String? driverPassword;
  String? timeSlot;

  BusDetails({
    this.vehicleNumber,
    this.driverName,
    this.driverPhone,
    this.driverCNIC,
    this.driverPassword,
    this.timeSlot,
  });
}
