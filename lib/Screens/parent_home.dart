import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

import 'chat_screen.dart';
import 'login_screen.dart';

class ParentHomeScreen extends StatelessWidget {
  final String parentName;
  final String childID;
  final String childName;

  ParentHomeScreen({
    required this.parentName,
    required this.childID,
    required this.childName,
  });

  void _signOut(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Future<String?> _fetchAssignedBusID() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('students')
        .where('studentNumber', isEqualTo: childID)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      var studentData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return studentData['assignedBusID'];
    }
    return null;
  }

  Future<bool> _checkForChats(String busID) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .where('bus_id', isEqualTo: busID)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $parentName'),
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
          mainAxisAlignment: MainAxisAlignment.start,
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
              height: 180,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('announcements').orderBy('date', descending: true).limit(3).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snapshot.data!.docs.map((document) {
                      var data = document.data() as Map<String, dynamic>?;
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
                          text: data['text'] ?? 'No text available',
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
            Text('Child Registration Number: $childID'),
            Text('Child Name: $childName'),
            FutureBuilder<String?>(
              future: _fetchAssignedBusID(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError || !snapshot.hasData) {
                  return Text('Error fetching bus ID or no bus assigned.');
                } else {
                  String? assignedBusID = snapshot.data;
                  return FutureBuilder<bool>(
                    future: assignedBusID != null ? _checkForChats(assignedBusID) : Future.value(false),
                    builder: (context, chatSnapshot) {
                      if (chatSnapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (chatSnapshot.hasError) {
                        return Text('Error checking for chats.');
                      } else if (chatSnapshot.data == true) {
                        return ElevatedButton(
                          child: Text('Go to Chat'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(busId: assignedBusID!,role: 'Parent',),
                              ),
                            );
                          },
                        );
                      } else {
                        return Text('No chat available for this bus.');
                      }
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

