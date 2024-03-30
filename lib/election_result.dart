import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionResult extends StatefulWidget {

  const ElectionResult({Key? key}) : super(key: key);

  @override
  State<ElectionResult> createState() => _ElectionResultState();
}

class _ElectionResultState extends State<ElectionResult> {
  List<Map<String, dynamic>> classCandidates = [];
  Future<List<Map<String, dynamic>>> fetchClassCandidates() async {
    classCandidates = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_college_candidate')
              .where('status', isGreaterThanOrEqualTo: 0)
              .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic>? studentData =
            await fetchStudent(doc['student_id']);
        if (studentData != null) {
          int voteCount = await fetchVoteCount(doc.id);
          String? position = await getPosition(doc['position_id']);
          Map<String, dynamic> combinedData = {
            ...doc.data(), // Spread the data from the document
            ...studentData, // Spread the student data
            'vote_count': voteCount,
            'position': position,
          };
          classCandidates.add(combinedData);
        }
      }
    } catch (e) {
      print("Error fetching class candidates: $e");
    }

    return classCandidates;
  }


  Future<Map<String, dynamic>?> fetchStudent(String id) async {

    try {
      final studentSnapshot = await FirebaseFirestore.instance
          .collection('tbl_studentregister')
          .doc(id)
          .get();

      if (studentSnapshot.exists) {
        Map<String, dynamic> studentData = studentSnapshot.data()!;
       
          return studentData; // Return student data if conditions are met
       
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
              .collection('tbl_college_polling')
              .where('candidate_id', isEqualTo: candidateId)
              .where('status', isEqualTo: 1)
              .get();
      return pollingSnapshot.size;
    } catch (e) {
      print("Error fetching vote count: $e");
      return 0; // Return 0 if any error occurs
    }
  }

  Future<String?> getPosition(String id) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> positionSnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_position')
              .doc(id)
              .get();
      if (positionSnapshot.exists) {
        String position = positionSnapshot['position_name'];
        return position;
      } else {
        print("Position document with ID $id does not exist");
        return null;
      }
    } catch (e) {
      print("Error fetching Position name: $e");
      return null;
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
        title: const Text('College Election Result'),
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
                            "Position: ${candidate['position']}",
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
