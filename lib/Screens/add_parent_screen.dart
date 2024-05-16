import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AddParentScreen extends StatefulWidget {
  @override
  _AddParentScreenState createState() => _AddParentScreenState();
}

class _AddParentScreenState extends State<AddParentScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _childNameController = TextEditingController();
  final TextEditingController _registrationNumberController = TextEditingController();
  final TextEditingController _parentNameController = TextEditingController();
  final TextEditingController _parentContactController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generateRandomPassword(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
      length,
          (_) => characters.codeUnitAt(rnd.nextInt(characters.length)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Parent")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _parentNameController,
                decoration: InputDecoration(labelText: 'Parent Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter parent name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _parentContactController,
                decoration: InputDecoration(labelText: 'Parent Contact Number'),
                validator: (value) {
                  if (value == null || value.isEmpty || !RegExp(r'^\d{11}$').hasMatch(value)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cnicController,
                decoration: InputDecoration(labelText: 'CNIC'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CNIC';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _childNameController,
                decoration: InputDecoration(labelText: 'Child Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter child name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _registrationNumberController,
                decoration: InputDecoration(labelText: 'Child Registration Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter registration number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _addParent();
                  }
                },
                child: Text('Add Parent'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addParent() async {
    try {
      // Check for existing parent with the same CNIC
      QuerySnapshot querySnapshot = await _firestore
          .collection('parents')
          .where('parentCNIC', isEqualTo: _cnicController.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If a parent with the same CNIC already exists, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Parent with this CNIC already exists')),
        );
      } else {
        // If no duplicate found, proceed to add the new parent
        String generatedPassword = generateRandomPassword(5);

        await _firestore.collection('parents').add({
          'parentName': _parentNameController.text,
          'parentContact': _parentContactController.text,
          'parentCNIC': _cnicController.text,
          'childName': _childNameController.text,
          'registrationNumber': _registrationNumberController.text,
          'password': generatedPassword,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Parent added successfully')),
        );
        _formKey.currentState?.reset();
        _parentNameController.clear();
        _parentContactController.clear();
        _cnicController.clear();
        _childNameController.clear();
        _registrationNumberController.clear();
      }
    } catch (e) {
      print('Failed to add parent: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add parent')),
      );
    }
  }
}
