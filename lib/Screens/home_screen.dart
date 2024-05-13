import 'package:edutrack/Screens/add_parent_screen.dart';
import 'package:edutrack/Screens/login_screen.dart';
import 'package:edutrack/Screens/view_parents_screen.dart';
import 'package:edutrack/Screens/students_screen.dart';
import 'package:edutrack/Screens/view_buses_screen.dart';
import 'package:edutrack/Screens/view_student_screen.dart';
import 'package:flutter/material.dart';

import 'bus_screen.dart';

class HomeScreen extends StatelessWidget {

  void _signOut(BuildContext context) {
    // Implement your sign-out logic here
    // For example:
    // Clear any user session data or tokens
    // Navigate to the login screen or any other screen after signing out
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        // Adjust the color to fit your theme
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              _signOut(context); // Call the sign-out function
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true, // Allows the GridView to take minimal space
              physics:
                  NeverScrollableScrollPhysics(), // Makes the GridView not scrollable
              crossAxisCount: 2,
              padding: EdgeInsets.all(16.0),
              crossAxisSpacing: 10.0,
              mainAxisSpacing: 10.0,
              children: <Widget>[
                _createDashboardItem(
                  context,
                  'Add Buses',
                  Icons.directions_bus,
                  Colors.orange,
                  () {
                    // Navigate to Add Buses Screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BusDetailsForm()));
                  },
                ),
                _createDashboardItem(
                  context,
                  'View Buses',
                  Icons.directions_bus,
                  Colors.lightBlue,
                  () {
                    // Navigate to View Buses Screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewBusesScreen()));

                  },
                ),
                _createDashboardItem(
                  context,
                  'Add Students',
                  Icons.school,
                  Colors.green,
                  () {
                    // Navigate to Add Students Screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddStudentScreen()));
                  },
                ),
                _createDashboardItem(
                  context,
                  'View Students',
                  Icons.school,
                  Colors.red,
                  () {
                    // Navigate to View Students Screen
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewStudentsScreen()));


                  },
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                width: double
                    .infinity, // Makes the button's width as wide as the screen
                child: ElevatedButton(
                  onPressed: () {
                    // Action for Add Parents
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddParentScreen()));

                  },
                  child: Text('Add Parents'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.purple, // Text color
                    padding: EdgeInsets.symmetric(
                        vertical: 20.0), // Button padding for larger touch area
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                width: double
                    .infinity, // Makes the button's width as wide as the screen
                child: ElevatedButton(
                  onPressed: () {
                    // Action for Add Parents
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewParentsScreen()));

                  },
                  child: Text('View Parents'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Colors.purpleAccent, // Text color
                    padding: EdgeInsets.symmetric(
                        vertical: 20.0), // Button padding for larger touch area
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createDashboardItem(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 50.0, color: Colors.white),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
