import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
                controller: _childNameController,
                decoration: InputDecoration(labelText: 'Child/Children Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter child/children name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _registrationNumberController,
                decoration: InputDecoration(labelText: 'Child/Children Registration Number'),
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
      await _firestore.collection('parents').add({
        'parentName': _parentNameController.text,
        'parentContact': _parentContactController.text,
        'childName': _childNameController.text,
        'registrationNumber': _registrationNumberController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parent added successfully')),
      );
      _formKey.currentState?.reset();
    } catch (e) {
      print('Failed to add parent: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add parent')),
      );
    }
  }
}
