import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BusDetailsForm extends StatefulWidget {
  @override
  _BusDetailsFormState createState() => _BusDetailsFormState();
}

class _BusDetailsFormState extends State<BusDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _busDetails = BusDetails();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addBus(BusDetails busDetails) async {
    try {
      await _firestore.collection('buses').add({
        'vehicleNumber': busDetails.vehicleNumber,
        'driverName': busDetails.driverName,
        'driverPhone': busDetails.driverPhone,
        'timeSlot': busDetails.timeSlot,
      });

      // Reset the form fields
      _formKey.currentState?.reset();

      // Show Snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bus added successfully')),
      );

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
                    // Access the provider and call addBus method
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
  String? timeSlot;

  BusDetails({
    this.vehicleNumber,
    this.driverName,
    this.driverPhone,
    this.timeSlot
  });
}
