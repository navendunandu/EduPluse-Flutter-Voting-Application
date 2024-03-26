import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

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
        _nameController = querySnapshot.docs.first['Student_name'];
        _contactController = querySnapshot.docs.first['Student_contact'];
        _addressController = querySnapshot.docs.first['Student_address'];
      });
    } else {
      setState(() {
        _nameController = 'Error Loading Data' as TextEditingController;
        _contactController = 'Error Loading Data' as TextEditingController;
        _addressController = 'Error Loading Data' as TextEditingController;
      });
    }
  }

  void editprofile() {
    print(_nameController.text);
    print(_contactController.text);
    print(_addressController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text('User editprofile'),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: 'Enter Name'),
            ),
            TextFormField(
              controller: _contactController,
              decoration: const InputDecoration(hintText: 'Enter Contact'),
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(hintText: 'Enter Address'),
            ),
            ElevatedButton(
                onPressed: () {
                  editprofile();
                },
                child: const Text('Save'))
          ],
        ),
      ),
    );
  }
}
