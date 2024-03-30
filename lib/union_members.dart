import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UnionMembers extends StatefulWidget {
  const UnionMembers({Key? key}) : super(key: key);

  @override
  State<UnionMembers> createState() => _UnionMembersState();
}

class _UnionMembersState extends State<UnionMembers> {
  List<Map<String, dynamic>> classCandidates = [];
  Future<List<Map<String, dynamic>>> fetchClassCandidates() async {
    classCandidates = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_college_candidate')
              .where('status', isGreaterThanOrEqualTo: 1)
              .where('winner', isEqualTo: 'true')
              .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic>? studentData =
            await fetchStudent(doc['student_id']);
        if (studentData != null) {
          String? position = await getPosition(doc['position_id']);
          Map<String, dynamic> combinedData = {
            ...doc.data(), // Spread the data from the document
            ...studentData, 
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
        title: const Text('Union Members'),
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
              return const Center(child: Text('No Union Members'));
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
