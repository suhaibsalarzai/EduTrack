import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class AnnouncementsPage extends StatefulWidget {
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  final TextEditingController _announcementController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Announcements'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('announcements').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: ListTile(
                          title: Text(document['text']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => document.reference.delete(),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _announcementController,
                decoration: InputDecoration(
                  labelText: 'New Announcement',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (_announcementController.text.isNotEmpty) {
                        FirebaseFirestore.instance.collection('announcements').add({
                          'text': _announcementController.text,
                          'date': FieldValue.serverTimestamp()  // Adding a timestamp
                        });
                        _announcementController.clear();
                      }
                    },

                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
