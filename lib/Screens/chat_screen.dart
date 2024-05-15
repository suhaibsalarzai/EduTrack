import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';  // Import intl for date formatting

class ChatPage extends StatefulWidget {
  final String busId;
  final String? role;

  ChatPage({required this.busId, this.role});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('buses').doc(widget.busId).get(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData && snapshot.data!.exists) {
                var vehicleNumber = snapshot.data!['vehicleNumber'];
                return Text("Chat for Bus $vehicleNumber");
              } else {
                return Text("Chat for Bus");
              }
            } else {
              return Text("Loading...");
            }
          },
        ),
        backgroundColor: Colors.deepPurple,
      ),

      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('chats').doc(widget.busId).collection('messages').orderBy('timestamp').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }

                List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var doc = docs[index];
                    var timestamp = doc['timestamp'] as Timestamp?;

                    // Format timestamp or use a placeholder if null
                    var formattedTimestamp = timestamp != null ? DateFormat('HH:mm').format(timestamp.toDate()) : "Timestamp missing";

                    // Determine if a date separator is needed
                    bool showDateHeader = timestamp != null && shouldShowDateHeader(docs, index, timestamp);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader)
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                timestamp != null ? DateFormat('yyyy-MM-dd').format(timestamp.toDate()) : "Date missing",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ),
                        ListTile(
                          title: Text(doc['text'] ?? "Message missing"),
                          subtitle: Text('Sender ID: ${doc['sender_id'] ?? "ID missing"}'),
                          trailing: Text(formattedTimestamp),
                        ),
                      ],
                    );
                  },
                );

              },
            ),
          ),
          if(widget.role != 'Student')
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.deepPurple),
                    onPressed: () => sendMessage(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool shouldShowDateHeader(List<QueryDocumentSnapshot> docs, int index, Timestamp? currentTimestamp) {
    if (index == 0) return true;  // Always show for the first message
    var previousTimestamp = docs[index - 1]['timestamp'] as Timestamp?;
    return previousTimestamp == null || currentTimestamp == null ||
        !isSameDate(previousTimestamp.toDate(), currentTimestamp.toDate());
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void sendMessage() {
    if (_messageController.text.isNotEmpty) {
      var message = _messageController.text.trim();
      _firestore.collection('chats').doc(widget.busId).collection('messages').add({
        'text': message,
        'sender_id': 'admin',  // Optionally replace 'admin' with actual admin user ID
        'timestamp': FieldValue.serverTimestamp(),
      });
      _messageController.clear();
    }
  }
}
