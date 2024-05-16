import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewStudentsScreen extends StatefulWidget {
  @override
  _ViewStudentsScreenState createState() => _ViewStudentsScreenState();
}

class _ViewStudentsScreenState extends State<ViewStudentsScreen> {
  late Future<List<QueryDocumentSnapshot>> _studentsFuture;
  List<QueryDocumentSnapshot> _students = [];
  List<QueryDocumentSnapshot> _buses = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudents();
    _fetchBuses();
  }

  Future<List<QueryDocumentSnapshot>> _fetchStudents() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('students').get();
      _students = querySnapshot.docs;
      return _students;
    } catch (e) {
      print('Failed to fetch students: $e');
      return [];
    }
  }

  Future<String> _getBusDetails(String? busId) async {
    if (busId == null) return 'Not Assigned';

    try {
      var busDoc = await _firestore.collection('buses').doc(busId).get();
      var busData = busDoc.data() as Map<String, dynamic>?;
      if (busData != null) {
        return '${busData['vehicleNumber'] ?? 'No Vehicle Number'} at ${busData['timeSlot'] ?? 'No Time Slot'}';
      }
    } catch (e) {
      print('Error fetching bus details: $e');
    }

    return 'Details Not Available';
  }

  Future<void> _deleteStudent(String studentId) async {
    try {
      await _firestore.collection('students').doc(studentId).delete();
      setState(() {
        _studentsFuture = _fetchStudents();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student deleted successfully')),
      );
    } catch (e) {
      print('Failed to delete student: $e');
    }
  }

  void _searchStudents(String registrationNumber) {
    print('the student number is $registrationNumber');
    List<QueryDocumentSnapshot> filteredStudents = _students.where((student) {
      print(' the database number is ${student['studentNumber']}');
      return student['studentNumber'].toLowerCase() == registrationNumber.toLowerCase();
    }).toList();
    print('the filtered students are ${filteredStudents}');
    if (filteredStudents.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Student Found'),
          content: Text('No student found with the registration number you searched for.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _studentsFuture = Future.value(filteredStudents);
      });
    }
  }

  Future<void> _fetchBuses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('buses').get();
      setState(() {
        _buses = querySnapshot.docs;
      });
    } catch (e) {
      print('Failed to fetch buses: $e');
      _buses = [];
    }
  }

  Future<String> _getBusName(String? busId) async {
    if (busId == null) return '';

    try {
      var busDoc = await _firestore.collection('buses').doc(busId).get();
      var busData = busDoc.data() as Map<String, dynamic>?;
      if (busData != null) {
        return busData['vehicleNumber'] ?? '';
      }
    } catch (e) {
      print('Error fetching bus details: $e');
    }

    return '';
  }

  Future<void> _showBusAssignmentDialog(String studentId, String? currentBusId) async {
    Map<String, String>? newBusDetails = await showDialog<Map<String, String>?>(
      context: context,
      builder: (BuildContext context) {
        String? selectedBusId = currentBusId;
        return AlertDialog(
          title: Text('Assign Bus'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Select a bus to assign:'),
                    DropdownButtonFormField<String>(
                      value: selectedBusId,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBusId = newValue;
                        });
                      },
                      items: _buses.map((DocumentSnapshot bus) {
                        return DropdownMenuItem<String>(
                          value: bus.id,
                          child: Text('${bus['vehicleNumber']} at ${bus['timeSlot']}'),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a bus';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedBusId != null) {
                  var selectedBus = _buses.firstWhere((bus) => bus.id == selectedBusId);
                  Navigator.pop(context, {
                    'id': selectedBus.id,
                    'details': '${selectedBus['vehicleNumber']} at ${selectedBus['timeSlot']}'
                  });
                }
              },
              child: Text('Assign'),
            ),
          ],
        );
      },
    );

    if (newBusDetails != null) {
      await _assignBus(studentId, newBusDetails['id'], newBusDetails['details']);
    }
  }

  Future<void> _assignBus(String studentId, String? busId, String? busDetails) async {
    try {
      await _firestore.collection('students').doc(studentId).update({
        'assignedBusID': busId,
        'busAssigned': busDetails,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bus assigned successfully')),
      );
    } catch (e) {
      print('Failed to assign bus: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to assign bus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Students")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Registration Number',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _studentsFuture = Future.value(_students);
                          });
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchStudents(_searchController.text.trim()),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _studentsFuture,
              builder: (context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<QueryDocumentSnapshot> students = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      var student = students[index];
                      String? busAssigned = student['assignedBusID'];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 4,
                          child: Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: Text(
                                    student['studentName'] ?? '',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Registration Number: ${student['studentNumber'] ?? ''}'),
                                      SizedBox(height: 4),
                                      FutureBuilder<String>(
                                        future: _getBusDetails(busAssigned),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return Text('Loading bus details...');
                                          } else if (snapshot.hasError) {
                                            return Text('Error loading bus details: ${snapshot.error}');
                                          } else {
                                            return Text('Assigned Bus: ${snapshot.data ?? 'Not Assigned'}');
                                          }
                                        },
                                      ),
                                      SizedBox(height: 4),
                                      Text('Contact Number: ${student['studentPhone'] ?? ''}'),
                                    ],
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _showBusAssignmentDialog(student.id, busAssigned),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () => _deleteStudent(student.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
