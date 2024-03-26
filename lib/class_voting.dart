import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClassVoting extends StatefulWidget {
  const ClassVoting({Key? key}) : super(key: key);

  @override
  State<ClassVoting> createState() => _ClassVotingState();
}

class _ClassVotingState extends State<ClassVoting> {
  List<Map<String, dynamic>> classCandidates = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchClassCandidates() async {
    List<Map<String, dynamic>> classCandidates = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_class_candidate')
              .get();

      for (var doc in querySnapshot.docs) {
        String docId = doc.id; // Get the document ID
        print('Document ID: $docId');

        print(doc['student_id']);
        Map<String, dynamic>? studentData =
            await fetchStudent(doc['student_id']);
        print('Student details: $studentData');

        if (studentData != null) {
          Map<String, dynamic> combinedData = {
            'document_id': docId, // Add document ID to combined data
            ...doc.data(), // Spread the data from the document
            ...studentData, // Spread the student data
          };
          classCandidates.add(combinedData);
        }
      }
    } catch (e) {
      print("Error fetching class candidates: $e");
    }

    return classCandidates;
  }

  Future<Map<String, dynamic>?> fetchMyClassDetails() async {
    Map<String, dynamic> details = {};

    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      QuerySnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
          .instance
          .collection('tbl_studentregister')
          .where('Student_id', isEqualTo: userId)
          .limit(1)
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        details['course_id'] = docSnapshot.docs.first['course_id'];
        details['year_id'] = docSnapshot.docs.first['year_id'];
      } else {
        print("No such document!");
      }
    } catch (e) {
      print("Error fetching class details: $e");
    }

    return details;
  }

  Future<Map<String, dynamic>?> fetchStudent(String id) async {
    Map<String, dynamic>? myClassDetails = await fetchMyClassDetails();
    String? courseId = myClassDetails!['course_id'];
    String? yearId = myClassDetails['year_id'];

    try {
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('tbl_studentregister')
          .doc(id)
          .get();

      if (studentSnapshot.exists) {
        Map<String, dynamic> studentData = studentSnapshot.data()!;
        // Check if the student belongs to the same course and year
        if (studentData['year_id'] == yearId &&
            studentData['course_id'] == courseId) {
          return studentData; // Return student data if conditions are met
        } else {
          return null; // Return null if student doesn't match course and year
        }
      } else {
        print('Student with id $id does not exist');
        return null; // Return null if student document doesn't exist
      }
    } catch (e) {
      print("Error fetching student details: $e");
      return null; // Return null if any error occurs
    }
  }

  Future<void> vote(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      DateTime now = DateTime.now();
      QuerySnapshot studentSnapshot = await firestore
          .collection('tbl_studentregister')
          .where('Student_id', isEqualTo: userId)
          .get();
      String documentId = studentSnapshot.docs.first.id;
      await firestore.collection('tbl_classpolling').add({
        'student_id': documentId,
        'candidate_id': id,
        'datetime': now,
        'polling_status': 1

        // Add more fields as needed
      });
      Fluttertoast.showToast(
        msg: "Vote Successfull",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error Voting $e');
      Fluttertoast.showToast(
        msg: "Voting Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClassCandidates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Candidates'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchClassCandidates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Check if the list is empty
            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('No candidates applied.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final candidate = snapshot.data![index];
                  return Card(
                    elevation: 4.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.network(
                          candidate['Student_photo'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            candidate['Student_name'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                print(candidate['document_id']);
                                vote(candidate['document_id']);
                              },
                              child: const Text('Vote'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
