import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import 'chat_screen.dart';
import 'login_screen.dart';

class DriverHomeScreen extends StatelessWidget {
  final String driverId;
  final String driverName;
  final String driverContact;
  final String assignedBus;

  DriverHomeScreen({
    required this.driverId,
    required this.driverName,
    required this.driverContact,
    required this.assignedBus,
  });

  Future<bool> _checkForChats() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('bus_id', isEqualTo: driverId)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  Future<List<QueryDocumentSnapshot>> _fetchAssignedStudents() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('assignedBusID', isEqualTo: driverId)
        .get();
    return querySnapshot.docs;
  }

  void _signOut(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $driverName'),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.blueAccent,
              child: Center(
                child: Text(
                  'Announcements',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Container(
              height: 180, // Fixed height to accommodate three marquees
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('announcements').orderBy('date', descending: true).limit(3).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snapshot.data!.docs.map((document) {
                      var data = document.data() as Map<String, dynamic>?; // Correct casting
                      if (data == null) {
                        return Container();
                      }

                      return Container(
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        height: 50,
                        child: Marquee(
                          text: data['text'] ?? 'No text available', // Now safely accessing data
                          style: TextStyle(fontWeight: FontWeight.bold),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          blankSpace: 50.0,
                          velocity: 70.0,
                          pauseAfterRound: Duration(seconds: 1),
                          showFadingOnlyWhenScrolling: true,
                          fadingEdgeStartFraction: 0.1,
                          fadingEdgeEndFraction: 0.1,
                          numberOfRounds: 3,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            Text('Contact: $driverContact'),
            Text('Assigned Bus: $assignedBus'),


            SizedBox(height: 20),
            Text('Assigned Students:',style: TextStyle(fontWeight: FontWeight.w700,fontSize: 20),),
            Expanded(
              child: FutureBuilder<List<QueryDocumentSnapshot>>(
                future: _fetchAssignedStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text('Error fetching students.');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No students assigned to this bus.');
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var student = snapshot.data![index];
                        var studentData = student.data() as Map<String, dynamic>;
                        return ListTile(
                          title: Text(studentData['studentName'] ?? 'No Name'),
                          subtitle: Text('ID: ${studentData['studentNumber'] ?? 'No ID'}'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Spacer(),
            SafeArea(
              child: FutureBuilder<bool>(
                future: _checkForChats(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error checking for chats.');
                  } else if (snapshot.data == true) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: Text('Go to Chats'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(busId: driverId,role: 'Driver',),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Text('No chats available.');
                  }
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
