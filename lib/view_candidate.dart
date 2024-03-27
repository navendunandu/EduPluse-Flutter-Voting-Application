import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewClassCandidate extends StatefulWidget {
  final String? eId;

  const ViewClassCandidate({Key? key, required this.eId}) : super(key: key);

  @override
  State<ViewClassCandidate> createState() => _ViewClassCandidateState();
}

class _ViewClassCandidateState extends State<ViewClassCandidate> {
  List<Map<String, dynamic>> classCandidates = [];
  Future<List<Map<String, dynamic>>> fetchClassCandidates() async {
    classCandidates = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_class_candidate')
              .where('election_id', isEqualTo: widget.eId)
              .where('candidate_status', isGreaterThanOrEqualTo: 1)
              .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic>? studentData =
            await fetchStudent(doc['student_id']);

        if (studentData != null) {
          Map<String, dynamic> combinedData = {
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
          return null;
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

  @override
  void initState() {
    super.initState();
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
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: snapshot.data!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final candidate = snapshot.data![index];
                  return Card(
                    elevation: 5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(
                          candidate['Student_photo'],
                          width: 100, // Adjust image size as needed
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          candidate['Student_name'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
