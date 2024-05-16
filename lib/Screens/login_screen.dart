import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edutrack/Screens/home_screen.dart';
import 'package:edutrack/Screens/parent_home.dart';
import 'package:edutrack/Screens/student_home.dart';
import 'package:flutter/material.dart';

import 'driver_home.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'Admin';

  void _login() async {
    String? errorMessage;

    if (_selectedRole == 'Admin') {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('id', isEqualTo: _idController.text)
          .where('password', isEqualTo: _passwordController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        if (userData['password'] == _passwordController.text) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          errorMessage = 'Invalid ID or password for Admin.';
        }
      } else {
        errorMessage = 'Invalid ID or password for Admin.';
      }
    } else if (_selectedRole == 'Student') {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('studentNumber', isEqualTo: _idController.text)
          .where('password', isEqualTo: _passwordController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var studentData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StudentHomePage(
              studentName: studentData['studentName'],
              assignedBusID: studentData['assignedBusID'],
              role: studentData['role'],
            ),
          ),
        );
      } else {
        errorMessage = 'Invalid ID or password for Student.';
      }
    } else if (_selectedRole == 'Parent') {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .where('parentCNIC', isEqualTo: _idController.text)
          .where('password', isEqualTo: _passwordController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var parentData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ParentHomeScreen(
              parentName: parentData['parentName'],
              childID: parentData['registrationNumber'],
              childName: parentData['childName'],
            ),
          ),
        );
      } else {
        errorMessage = 'Invalid CNIC or password for Parent.';
      }
    } else if (_selectedRole == 'Driver') {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('buses')
          .where('driverCNIC', isEqualTo: _idController.text)
          .where('driverPassword', isEqualTo: _passwordController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var driverDoc = querySnapshot.docs.first;
        var driverData = driverDoc.data() as Map<String, dynamic>;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DriverHomeScreen(
              driverId: driverDoc.id,
              driverName: driverData['driverName'],
              driverContact: driverData['driverPhone'],
              assignedBus: driverData['vehicleNumber'],
            ),
          ),
        );
      } else {
        errorMessage = 'Invalid CNIC or password for Driver.';
      }
    } else {
      errorMessage = 'Role not supported.';
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/img.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'EduTrack',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28.0,
                  fontWeight: FontWeight.w800,
                  color: Colors.deepPurple,
                ),
              ),
              SizedBox(height: 68.0),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  labelText: _selectedRole == 'Parent' || _selectedRole == 'Driver'
                      ? 'CNIC'
                      : 'Registration Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8.0),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24.0),
              DropdownButtonFormField(
                value: _selectedRole,
                items: <String>['Admin', 'Parent', 'Student', 'Driver']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Role',
                ),
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                child: Text(
                  'Login',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                onPressed: _login,
              ),
              SizedBox(height: 12.0),
            ],
          ),
        ),
      ),
    );
  }
}

