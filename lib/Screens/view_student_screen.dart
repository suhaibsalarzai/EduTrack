
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

// Fetch students data
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

// Delete student
  Future<void> _deleteStudent(String studentId) async {
    try {
      await _firestore.collection('students').doc(studentId).delete();
      setState(() {
        _studentsFuture = _fetchStudents(); // Refresh the student list after deletion
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student deleted successfully')),
      );
    } catch (e) {
      print('Failed to delete student: $e');
    }
  }


  void _searchStudents(String registrationNumber) {
    print('the studnent numer is $registrationNumber');
    List<QueryDocumentSnapshot> filteredStudents = _students.where((student) {
      print(' the database numer is ${student['studentNumber']}');
      return student['studentNumber'].toLowerCase() == registrationNumber.toLowerCase();
    }).toList();
    print('the filterd studnets are ${filteredStudents}');
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


  // Existing methods (e.g., _deleteStudent, _assignBus, _fetchBuses, _getBusName, _showBusAssignmentDialog)
  // have not been modified and should be included here without changes.
  // Fetch buses data
  Future<void> _fetchBuses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('buses').get();
      setState(() {
        _buses = querySnapshot.docs;
      });
    } catch (e) {
      print('Failed to fetch buses: $e');
      _buses = []; // Ensure _buses is initialized as an empty list
    }
  }


  // Get bus name by busId
  Future<String> _getBusName(String? busId) async {
    if (busId == null) return '';


    try {
      var busDoc = await _firestore.collection('buses').doc(busId).get();
      var busData = busDoc.data() as Map<String, dynamic>?;
      if (busData != null ) {
        return busData['vehicleNumber'] ?? '';
      }
    } catch (e) {
      print('Error fetching bus details: $e');
    }


    return '';
  }


  // Show dialog for bus assignment
  Future<void> _showBusAssignmentDialog(String studentId, String? currentBusId) async {
    String? newBusId = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Assign Bus'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Select a bus to assign:'),
                DropdownButtonFormField<String>(
                  value: currentBusId,
                  onChanged: (newValue) {
                    Navigator.pop(context, newValue);
                  },
                  items: _buses.map((bus) {
                    return DropdownMenuItem<String>(
                      value: bus.id,
                      child: Text(bus['vehicleNumber'] ?? ''),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );


    if (newBusId != null) {
      _assignBus(studentId, newBusId);
    }
  }


  // Assign bus to student
  Future<void> _assignBus(String studentId, String? busId) async {
    try {
      await _firestore.collection('students').doc(studentId).update({
        'busAssigned': busId,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bus assigned successfully')),
      );
    } catch (e) {
      print('Failed to assign bus: $e');
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
                            _studentsFuture = Future.value(_students); // Reset list to all students
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
                      String? busAssigned = student['busAssigned'];
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
                                        future: _getBusName(busAssigned),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.waiting) {
                                            return Text('Loading bus details...');
                                          } else if (snapshot.hasError) {
                                            return Text('Error loading bus details: ${snapshot.error}');
                                          } else {
                                            return Text('Assigned Vehicle Number: ${snapshot.data ?? 'Not Assigned'}');
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

