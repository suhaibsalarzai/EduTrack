import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewBusesScreen extends StatefulWidget {
  @override
  _ViewBusesScreenState createState() => _ViewBusesScreenState();
}

class _ViewBusesScreenState extends State<ViewBusesScreen> {
  late Future<List<QueryDocumentSnapshot>> _busesFuture;
  final TextEditingController _searchController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _busesFuture = _fetchBuses();
  }

  Future<List<QueryDocumentSnapshot>> _fetchBuses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('buses').get();
      return querySnapshot.docs;
    } catch (e) {
      print('Failed to fetch buses: $e');
      return [];
    }
  }

  Future<void> _deleteBus(String busId) async {
    try {
      await _firestore.collection('buses').doc(busId).delete();
      setState(() {
        _busesFuture = _fetchBuses(); // Refresh the bus list after deletion
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bus deleted successfully')),
      );
    } catch (e) {
      print('Failed to delete bus: $e');
    }
  }

  void _searchVehicles(String vehicleNumber) {
    setState(() {
      _busesFuture = _fetchBuses().then((buses) => buses.where((bus) =>
          bus['vehicleNumber']
              .toString()
              .toLowerCase()
              .contains(vehicleNumber.toLowerCase())).toList());
    });
  }

  Future<int> _getStudentCount(String busId) async {
    var querySnapshot = await _firestore.collection('students')
        .where('assignedBusID', isEqualTo: busId)
        .get();
    return querySnapshot.docs.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Buses")),
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
                      labelText: 'Search by Vehicle Number',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _busesFuture = _fetchBuses();
                          });
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () => _searchVehicles(_searchController.text.trim()),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _busesFuture,
              builder: (context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  List<QueryDocumentSnapshot> buses = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: buses.length,
                    itemBuilder: (context, index) {
                      var bus = buses[index];
                      return FutureBuilder<int>(
                        future: _getStudentCount(bus.id),
                        builder: (context, studentCountSnapshot) {
                          int studentCount = studentCountSnapshot.data ?? 0;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              elevation: 4,
                              child: ListTile(
                                title: Text(
                                  bus['driverName'] ?? '',
                                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Time Slot: ${bus['timeSlot'] ?? ''}'),
                                    SizedBox(height: 4),
                                    Text('Vehicle Number: ${bus['vehicleNumber'] ?? ''}'),
                                    SizedBox(height: 4),
                                    Text('Contact Number: ${bus['driverPhone'] ?? ''}'),
                                    SizedBox(height: 4),
                                    Text('Assigned Students: $studentCount'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteBus(bus.id),
                                ),
                              ),
                            ),
                          );
                        },
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
