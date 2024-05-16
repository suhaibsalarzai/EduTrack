import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AddStudentScreen extends StatefulWidget {
  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentDetails = StudentDetails();
  List<DropdownMenuItem<String>> _busOptions = [];
  String? _selectedBus;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchBuses();
  }

  String generateRandomPassword(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
          (_) => characters.codeUnitAt(rnd.nextInt(characters.length)),
    ));
  }

  Future<void> createChatRoomIfNeeded(String busId) async {
    try {
      DocumentReference busChatRef = _firestore.collection('chats').doc(busId);
      DocumentSnapshot busChatSnapshot = await busChatRef.get();

      if (!busChatSnapshot.exists) {
        await busChatRef.set({
          'created_at': FieldValue.serverTimestamp(),
          'bus_id': busId,
          'messages': [],
        });
        print("Chat room created for bus: $busId");
      }
    } catch (e) {
      print('Failed to create chat room: $e');
    }
  }

  Future<void> _fetchBuses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('buses').get();
      var buses = <DropdownMenuItem<String>>[];
      for (var doc in querySnapshot.docs) {
        String vehicleNumber = doc['vehicleNumber'];
        String timeSlot = doc['timeSlot'];
        buses.add(DropdownMenuItem(
          value: doc.id,
          child: Text('$vehicleNumber - $timeSlot'),
        ));
      }
      setState(() {
        _busOptions = buses;
      });
    } catch (e) {
      print('Failed to fetch buses: $e');
    }
  }

  Future<void> addStudent(StudentDetails studentDetails) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('students')
          .where('studentNumber', isEqualTo: studentDetails.studentNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student with this Registration Number already exists')),
        );
      } else {
        await _firestore.collection('students').add({
          'studentNumber': studentDetails.studentNumber,
          'studentName': studentDetails.studentName,
          'studentPhone': studentDetails.studentPhone,
          'busAssigned': studentDetails.busAssigned,
          'assignedBusID': studentDetails.assignedBusID,
          'password': studentDetails.password,
          'role': 'Student',
        });

        if (studentDetails.assignedBusID != null) {
          await createChatRoomIfNeeded(studentDetails.assignedBusID!);
        }

        _formKey.currentState?.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student added successfully')),
        );
      }
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
                items: _busOptions,
                validator: (value) => value == null ? 'Please select a bus' : null,
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState!.save();
                    _studentDetails.password = generateRandomPassword(5);

                    var selectedBusDisplay = _busOptions.firstWhere(
                            (option) => option.value == _selectedBus,
                        orElse: () => DropdownMenuItem<String>(value: '', child: Text('No Bus Selected'))
                    ).child as Text;

                    _studentDetails.busAssigned = selectedBusDisplay.data;
                    _studentDetails.assignedBusID = _selectedBus;
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
  String? assignedBusID;
  String? password;
  String? role = 'Student';

  StudentDetails({
    this.studentNumber,
    this.studentName,
    this.studentPhone,
    this.busAssigned,
    this.assignedBusID,
    this.password,
    this.role,
  });
}
