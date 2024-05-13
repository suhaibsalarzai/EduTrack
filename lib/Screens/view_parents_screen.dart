import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class ParentData extends ChangeNotifier {
  List<QueryDocumentSnapshot>? _allParents;
  List<QueryDocumentSnapshot>? _originalParents;

  List<QueryDocumentSnapshot>? get allParents => _allParents;

  Future<void> fetchParents(FirebaseFirestore firestore) async {
    try {
      QuerySnapshot querySnapshot =
      await firestore.collection('parents').get();
      _allParents = querySnapshot.docs;
      _originalParents = _allParents!.toList(); // Store a copy of original data
    } catch (e) {
      print('Failed to fetch parents: $e');
      _allParents = [];
      _originalParents = [];
    }
    notifyListeners();
  }

  void searchParent(String query, BuildContext context) {
    print('The search is for $query');
    if (_originalParents != null) {
      if (query.isEmpty) {
        _allParents = _originalParents!.toList(); // Reset to original list
      } else {
        _allParents = _originalParents!
            .where((parent) =>
            parent['parentName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();

        // Check if the resulting list is empty and show an alert if it is
        if (_allParents!.isEmpty) {
          print('No parents found.');
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Search Result"),
                content: Text("No parent found with that name."),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        } else {
          print('the searched outcome is ${_allParents?.first}');
        }
      }
    }
    notifyListeners(); // Notify listeners after updating the _allParents list
  }

  Future<void> deleteParent(BuildContext context, FirebaseFirestore firestore, String parentId) async {
    try {
      await firestore.collection('parents').doc(parentId).delete();
      await fetchParents(firestore); // Refresh the parent list after deletion
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parent deleted successfully')),
      );
    } catch (e) {
      print('Failed to delete parent: $e');
    }
  }
}

class ViewParentsScreen extends StatefulWidget {
  @override
  _ViewParentsScreenState createState() => _ViewParentsScreenState();
}

class _ViewParentsScreenState extends State<ViewParentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch parents data when the screen initializes
    Provider.of<ParentData>(context, listen: false)
        .fetchParents(FirebaseFirestore.instance);
  }

  // Function to reset the search query and show all parents
  void resetSearch() {
    _searchController.clear(); // Clear the search query
    Provider.of<ParentData>(context, listen: false)
        .searchParent('',context); // Reset to show all parents
    setState(() {}); // Update UI after resetting search
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View Parents"),
      ),
      body: FutureBuilder(
        future: Provider.of<ParentData>(context, listen: false).fetchParents(FirebaseFirestore.instance),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while data is being fetched
            return Center(child: CircularProgressIndicator());
          } else {
            // Once data is fetched, build the UI
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Search Parent',
                            border: OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: resetSearch, // Reset search query and show all parents
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          Provider.of<ParentData>(context, listen: false)
                              .searchParent(_searchController.text, context); // Pass context
                          // Update UI after searching
                        },
                      ),

                    ],
                  ),
                ),
                Expanded(
                  child: Consumer<ParentData>(
                    builder: (context, parentData, child) {
                      List<QueryDocumentSnapshot>? parents = parentData.allParents;
                      if (parents == null) {
                        return Center(child: Text('No data available.'));
                      } else if (parents.isEmpty) {
                        return Center(child: Text('No parents found.'));
                      } else {
                        return ListView.builder(
                          itemCount: parents.length,
                          itemBuilder: (context, index) {
                            var parent = parents[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Card(
                                child: ListTile(
                                  title: Text(
                                    parent['parentName'] ?? '',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      'Contact Number: ${parent['parentContact'] ?? ''}'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      Provider.of<ParentData>(context, listen: false)
                                          .deleteParent(
                                          context,
                                          FirebaseFirestore.instance,
                                          parent.id);
                                    },
                                  ),
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
            );
          }
        },
      ),
    );
  }
}
