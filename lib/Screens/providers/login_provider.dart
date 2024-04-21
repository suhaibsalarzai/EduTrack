import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirestoreAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> loginWithCredentials(String id, String password, String role) async {
    try {
      // Query the database for a user with the given id
      QuerySnapshot snapshot = await _firestore.collection('users')
          .where('id', isEqualTo: id)
          .where('password', isEqualTo: password)
          .where('role', isEqualTo: role)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return "Invalid credentials or role. Please contact admin.";
      } else {
        return null; // Login successful
      }
    } catch (e) {
      return "Error accessing data. Please try again.";
    }
  }
}
