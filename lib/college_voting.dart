import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ClgVoting extends StatefulWidget {
  const ClgVoting({Key? key}) : super(key: key);

  @override
  State<ClgVoting> createState() => _ClgVotingState();
}

class _ClgVotingState extends State<ClgVoting> {
  late Future<List<Map<String, dynamic>>> positionData = Future.value([]);
  List<String> selectedDropdowns = [];

  @override
  void initState() {
    super.initState();
    positionData = fetchData();
  }

  Future<List<Map<String, dynamic>>> fetchData() async {
    try {
      List<Map<String, dynamic>> dataList = [];
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('tbl_position').get();
      for (var doc in querySnapshot.docs) {
        List<Map<String, dynamic>> candidates = await fetchCandidates(doc.id);
        Map<String, dynamic> datas = {
          "position_id": doc.id,
          "position_name": doc['position_name'],
          "candidates": candidates,
        };
        dataList.add(datas);
      }
      return dataList;
    } catch (e) {
      print('Error fetching position data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchCandidates(String id) async {
    try {
      QuerySnapshot<Map<String, dynamic>> candidateSnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_college_candidate')
              .where('position_id', isEqualTo: id)
              .where('status', isEqualTo: 1)
              .get();
      List<Map<String, dynamic>> candidates = [];
      for (var candidateDoc in candidateSnapshot.docs) {
        String studentId = candidateDoc['student_id'];
        String? studentName = await fetchStudentName(studentId);
        if (studentName != null) {
          candidates.add({
            'id': candidateDoc.id,
            'name': studentName,
          });
        }
      }
      return candidates;
    } catch (e) {
      print("Error fetching candidates for position $id: $e");
      return [];
    }
  }

  Future<String?> fetchStudentName(String studentId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> studentSnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_studentregister')
              .doc(studentId)
              .get();
      if (studentSnapshot.exists) {
        String studentName = studentSnapshot['Student_name'];
        return studentName;
      } else {
        print("Student document with ID $studentId does not exist");
        return null;
      }
    } catch (e) {
      print("Error fetching student name: $e");
      return null;
    }
  }

  Future<void> vote(String id, String name) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      DateTime now = DateTime.now();
      QuerySnapshot<Map<String, dynamic>> studentSnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_studentregister')
              .where('Student_id', isEqualTo: userId)
              .get();
      String documentId = studentSnapshot.docs.first.id;
      await firestore.collection('tbl_college_polling').add({
        'student_id': documentId,
        'candidate_id': id,
        'datetime': now,
        'status': 0

        // Add more fields as needed
      });
      Fluttertoast.showToast(
        msg: "Voted for $name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      setState(() {
        selectedDropdowns.add(id); // Mark the dropdown as selected
      });
    } catch (e) {
      print('Voting Error $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Election'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: positionData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Map<String, dynamic>> positions = snapshot.data ?? [];
            return ListView.builder(
              itemCount: positions.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> position = positions[index];
                List<Map<String, dynamic>> candidates =
                    position['candidates'] ?? [];
                return ListTile(
                  title: Text(position['position_name']),
                  subtitle: DropdownButtonFormField<String>(
                    items: selectedDropdowns.contains(position['position_id'])
                        ? [] // If the dropdown has been selected, show an empty list
                        : candidates.map<DropdownMenuItem<String>>((candidate) {
                            return DropdownMenuItem<String>(
                              value: candidate['id'],
                              child: Text(candidate['name']),
                            );
                          }).toList(),
                    onChanged: selectedDropdowns
                            .contains(position['position_id'])
                        ? null // Disable the dropdown if the position ID is in selectedDropdowns
                        : (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedDropdowns.add(position['position_id']);
                              });
                              vote(newValue, position['position_name']);
                            }
                          },
                    hint: selectedDropdowns.contains(position['position_id'])
                        ? const Text(
                            'Voted') // Show "Voted" as a hint when the dropdown is disabled
                        : null,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
