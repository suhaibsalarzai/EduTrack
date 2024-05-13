import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddStudentScreen extends StatefulWidget {
  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentDetails = StudentDetails();
  List<String> _busOptions = [];
  String? _selectedBus;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchBuses();
  }

  Future<void> _fetchBuses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('buses').get();
      List<String> buses = [];
      querySnapshot.docs.forEach((doc) {
        String vehicleNumber = doc['vehicleNumber'];
        String timeSlot = doc['timeSlot'];
        buses.add('$vehicleNumber - $timeSlot');
      });
      setState(() {
        _busOptions = buses;
      });
    } catch (e) {
      print('Failed to fetch buses: $e');
    }
  }

  Future<void> addStudent(StudentDetails studentDetails) async {
    try {
      await _firestore.collection('students').add({
        'studentNumber': studentDetails.studentNumber,
        'studentName': studentDetails.studentName,
        'studentPhone': studentDetails.studentPhone,
        'busAssigned': studentDetails.busAssigned,
      });

      // Clear the form fields
      _formKey.currentState?.reset();

      // Show a Snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student added successfully')),
      );

    } catch (e) {
      throw Exception('Failed to add student: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Student Details")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'Registration Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Student ID';
                  }
                  return null;
                },
                onSaved: (value) {
                  _studentDetails.studentNumber = value!;
                },
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Student Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter student name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _studentDetails.studentName = value!;
                },
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Student Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^\d{11}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _studentDetails.studentPhone = value!;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Select a Bus"),
                value: _selectedBus,
                onChanged: (newValue) {
                  setState(() {
                    _selectedBus = newValue;
                  });
                },
                items: _busOptions.map((String bus) {
                  return DropdownMenuItem<String>(
                    value: bus,
                    child: Text(bus),
                  );
                }).toList(),
                validator: (value) => value == null ? 'Please select a bus' : null,
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState!.save();
                    _studentDetails.busAssigned = _selectedBus;
                    // Access the provider and call addStudent method
                    addStudent(_studentDetails);
                  }
                },
                child: Text('Add Student'),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

class StudentDetails {
  String? studentNumber;
  String? studentName;
  String? studentPhone;
  String? busAssigned;

  StudentDetails({
    this.studentNumber,
    this.studentName,
    this.studentPhone,
    this.busAssigned
  });
}
