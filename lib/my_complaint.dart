import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComplaintsPage extends StatefulWidget {
  const ComplaintsPage({Key? key});

  @override
  _ComplaintsPageState createState() => _ComplaintsPageState();
}

class _ComplaintsPageState extends State<ComplaintsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Complaints'),
      ),
      body: ComplaintsList(), // Removed const keyword here
    );
  }
}

class ComplaintsList extends StatelessWidget {
  const ComplaintsList({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getStudentData(), // Call getStudentData() here
      builder: (BuildContext context, AsyncSnapshot<String?> uidSnapshot) {
        if (uidSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (uidSnapshot.hasError) {
          return const Center(
            child: Text('Error fetching student data'),
          );
        }

        final String? uid = uidSnapshot.data;
        if (uid == null) {
          return const Center(
            child: Text('User ID not found'),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tbl_complaint')
              .where('student_id', isEqualTo: uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['complaint_title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['complaint_content']),
                      Text(data['status'] == 0 && data['reply'].isEmpty
                          ? 'Not reviewed by admin'
                          : 'Reply:${data["reply"]}'),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Future<String?> getStudentData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    // Make the Firestore query and wait for the result
    QuerySnapshot<Map<String, dynamic>> studentSnapshot = await FirebaseFirestore
        .instance
        .collection('tbl_studentregister')
        .where('Student_id', isEqualTo: userId)
        .get();

    // Check if the query returned any documents
    if (studentSnapshot.docs.isNotEmpty) {
      // Return the ID of the first document in the snapshot
      return studentSnapshot.docs.first.id;
    } else {
      // No document found, return null or handle the case accordingly
      return null;
    }
  }
}
