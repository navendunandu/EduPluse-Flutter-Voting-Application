import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewResult extends StatefulWidget {
  final String? eId;

  const ViewResult({Key? key, required this.eId}) : super(key: key);

  @override
  State<ViewResult> createState() => _ViewResultState();
}

class _ViewResultState extends State<ViewResult> {
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
          int voteCount = await fetchVoteCount(doc.id);
          Map<String, dynamic> combinedData = {
            ...doc.data(), // Spread the data from the document
            ...studentData, // Spread the student data
            'vote_count': voteCount,
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

  Future<int> fetchVoteCount(String candidateId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> pollingSnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_classpolling')
              .where('candidate_id', isEqualTo: candidateId)
              .where('polling_status', isEqualTo: 1)
              .get();

      return pollingSnapshot.size;
    } catch (e) {
      print("Error fetching vote count: $e");
      return 0; // Return 0 if any error occurs
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
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey, // Border color
                        width: 1, // Border width
                      ),
                      borderRadius: BorderRadius.circular(10), // Border radius
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5), // Shadow color
                          spreadRadius: 2, // Spread radius
                          blurRadius: 4, // Blur radius
                          offset: const Offset(0, 2), // Shadow offset
                        ),
                      ],
                    ),
                    child: FittedBox(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            candidate['Student_photo'],
                            fit: BoxFit.cover,
                            height: 120,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            candidate['Student_name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Votes: ${candidate['vote_count']}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (candidate['winner'] ==
                              'true') // Check if candidate is a winner
                            Container(
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 8, left: 25, right: 25),
                              decoration: const BoxDecoration(
                                color: Colors.green, // Winner banner color
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Winner',
                                style: TextStyle(
                                  color:
                                      Colors.white, // Winner banner text color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                        ],
                      ),
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
