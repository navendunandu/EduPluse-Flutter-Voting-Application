// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
        .instance
        .collection('tbl_studentregister')
        .where('Student_id', isEqualTo: userId)
        .limit(1)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      setState(() {
        _nameController.text = querySnapshot.docs.first['Student_name'];
        _contactController.text = querySnapshot.docs.first['Student_contact'];
        _addressController.text = querySnapshot.docs.first['Student_address'];
      });
    } else {
      setState(() {
        _nameController.text = 'Error Loading Data';
        _contactController.text = 'Error Loading Data';
        _addressController.text = 'Error Loading Data';
      });
    }
  }

  Future<void> editprofile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;

      if (userId != null) {
        try {
          await FirebaseFirestore.instance
              .collection('tbl_studentregister')
              .where('Student_id', isEqualTo: userId)
              .get()
              .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              final docId = querySnapshot.docs.first.id;
              FirebaseFirestore.instance
                  .collection('tbl_studentregister')
                  .doc(docId)
                  .update({
                'Student_name': _nameController.text,
                'Student_contact': _contactController.text,
                'Student_address': _addressController.text,
              });
              Fluttertoast.showToast(
        msg: "Profile updated successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
            }
          });
        } catch (e) {
          Fluttertoast.showToast(
        msg: "Error",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
          print('Error updating document: $e');
        }
      } else {
        Fluttertoast.showToast(
        msg: "User ID is null",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
        print('User ID is null');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 50,
                ),
                const Text('User editprofile'),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Enter Name'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _contactController,
                  decoration: const InputDecoration(hintText: 'Enter Contact'),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(hintText: 'Enter Address'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () {
                      editprofile();
                    },
                    child: const Text('Save'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
