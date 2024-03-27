import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class CgCandApp extends StatefulWidget {
  const CgCandApp({super.key});

  @override
  State<CgCandApp> createState() => _CgCandAppState();
}

class _CgCandAppState extends State<CgCandApp> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> postList = [];

  String? _selectedPost;

  Future<void> fetchPostData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('tbl_position').get();

      List<Map<String, dynamic>> post = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['position_name'].toString(),
              })
          .toList();

      setState(() {
        postList = post;
      });
    } catch (e) {
      print('Error fetching position data: $e');
    }
  }

  

  Future<void> apply() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      DateTime currentDate = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      QuerySnapshot studentSnapshot = await firestore
          .collection('tbl_studentregister')
          .where('Student_id', isEqualTo: userId)
          .get();
      String documentId = studentSnapshot.docs.first.id;
      await firestore.collection('tbl_college_candidate').add({
        "position_id": _selectedPost,
        "status": 0,
        "submission_date": formattedDate,
        "winner": "",
        "student_id": documentId
      });
      Fluttertoast.showToast(
          msg: "Candidate Applied",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print('Application Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPostData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Candidate Application'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  DropdownButtonFormField<String>(
                    value: _selectedPost,
                    hint: const Text('Select an option'),
                    isExpanded: true,
                    items: postList.map<DropdownMenuItem<String>>(
                      (Map<String, dynamic> year) {
                        return DropdownMenuItem<String>(
                          value: year['id'],
                          child: Text(year['name']),
                        );
                      },
                    ).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPost = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an option';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          apply();
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
