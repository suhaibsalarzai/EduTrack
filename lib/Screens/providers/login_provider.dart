import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> loginWithCredentials(String id, String password, String role) async {
    try {
      // Query the database for a user with the given id
      QuerySnapshot snapshot = await _firestore.collection('users')
          .where('id', isEqualTo: id)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // No user found with the provided id
        return "Invalid credentials. Please contact admin.";
      } else {
        // User found with the provided id, check password and role
        var userDoc = snapshot.docs.first;
        print('user passord is ${userDoc['password']}');
        print('user role is ${userDoc['role']}');
        print('user passord from appis ${password}');
        print('user role from appis ${role}');


        if (userDoc['password'] != password || userDoc['role'] != role) {
          // Password or role does not match
          return "Invalid pasword or role. Please contact admin.";
        } else {
          // Password and role match, login successful
          return null;
        }
      }
    } catch (e) {
      // Error accessing data
      return "Error accessing data. Please try again.";
    }
  }
}
