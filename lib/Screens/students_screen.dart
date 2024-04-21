import 'package:flutter/material.dart';

class AddStudentScreen extends StatefulWidget {
  @override
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _busDetails = StudentDetails();

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
                  _busDetails.studentNumber = value!;
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
                  _busDetails.studentName = value!;
                },
              ),

              TextFormField(
                decoration: InputDecoration(labelText: 'Student Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _busDetails.studentPhone = value!;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Select a Bus"),
                value: _busDetails.busAssigned,
                onChanged: (newValue) {
                  setState(() {
                    _busDetails.busAssigned = newValue;
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing Data')),
                    );
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

