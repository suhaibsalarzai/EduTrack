import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:marquee/marquee.dart';
import 'chat_screen.dart';
import 'login_screen.dart';

class StudentHomePage extends StatefulWidget {
  final String studentName;
  final String assignedBusID;
  final String role;

  const StudentHomePage({required this.studentName, required this.assignedBusID, required this.role});

  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {

  void _signOut(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.studentName),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Column(
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
          Container(
            height: MediaQuery.of(context).size.height *0.15,
            padding: EdgeInsets.all(16.0),
            child: FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('buses').doc(widget.assignedBusID).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData && snapshot.data!.exists) {
                    var busData = snapshot.data!.data() as Map<String, dynamic>;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(

                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text("Assigned Vehicle: ${busData['vehicleNumber']}"),
                              Text("Driver Name: ${busData['driverName']}"),
                              Text("Driver Contact: ${busData['driverPhone']}"),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Text("No bus details available.");
                  }
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Spacer(),
          SafeArea(
            child: Container(
              width: MediaQuery.of(context).size.width*0.8,  // This makes the container take the full width of its parent
              padding: EdgeInsets.all(8.0),  // Optional padding
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)  // Optional rounded corners
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(busId: widget.assignedBusID, role: widget.role),
                    ),
                  );
                },
                child: Text('Go to Chat'),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
