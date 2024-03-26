import 'package:edupulse/class_voting.dart';
import 'package:edupulse/view_candidate.dart';
import 'package:edupulse/view_class_result.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ElectionDashboard extends StatefulWidget {
  const ElectionDashboard({super.key});

  @override
  State<ElectionDashboard> createState() => _ElectionDashboardState();
}

class _ElectionDashboardState extends State<ElectionDashboard> {
  String? eDetails;
  String? eDate;
  String? eforDate;
  String? elastDate;
  String? eid;
  String? eStatus;

  bool cVote = false;
  bool cgVote = false;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> cVoteCheck() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      QuerySnapshot studentSnapshot = await firestore
          .collection('tbl_studentregister')
          .where('Student_id', isEqualTo: userId)
          .get();
      String documentId = studentSnapshot.docs.first.id;
      final result = await FirebaseFirestore.instance
          .collection('tbl_classpolling')
          .where('student_id', isEqualTo: documentId)
          .get();
      if (result.docs.isEmpty) {
        setState(() {
          cVote = true;
        });
      }
    } catch (e) {
      print('Error checking vote: $e');
    }
  }

  Future<void> cgVoteCheck() async {
     try {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    QuerySnapshot<Map<String, dynamic>> studentSnapshot = await FirebaseFirestore.instance
        .collection('tbl_studentregister')
        .where('Student_id', isEqualTo: userId)
        .get();
    String documentId = studentSnapshot.docs.first.id;
    
    // Check if the user has already applied for this election
   DocumentSnapshot<Map<String, dynamic>>? snapshot = await FirebaseFirestore.instance
    .collection('tbl_class_candidate')
    .where('student_id', isEqualTo: documentId)
    .where('election_id', isEqualTo: eid)
    .limit(1) // Limit to 1 document
    .get()
    .then((value) => value.docs.isNotEmpty ? value.docs.first : null);

    print("Winner? : ${snapshot!.data()?['winner']}");
    if (snapshot!.data()?['winner'] == 'true') {
      // Document exists, show an error message
      setState(() {
        cgVote = true;
      });
    }
  } catch (e) {
    print("Error checking candidate status: $e");
  }
  }

  void fetchDataFromFirestore() async {
    try {
      // Access the Firestore instance

      // Access the collection "tbl_election"
      CollectionReference elections = firestore.collection('tbl_election');

      // Perform a query to fetch data
      QuerySnapshot querySnapshot = await elections.get();

      // Loop through the documents and access the data
      querySnapshot.docs.forEach((doc) {
        setState(() {
          eid = doc.id;
          eDetails = doc['election_details'];
          eDate = doc['election_date'];
          eforDate = doc['election_for_date'];
          elastDate = doc['election_nomination_ldate'];
          eStatus = doc['election_status'].toString();
        });
        print(eStatus);
        // Access other fields similarly
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> applyCandidate() async {
    // _progressDialog.show();
    DateTime currentDate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;
    QuerySnapshot studentSnapshot = await firestore
        .collection('tbl_studentregister')
        .where('Student_id', isEqualTo: userId)
        .get();
    String documentId = studentSnapshot.docs.first.id;
    try {
      // Check if a document with the same student_id and election_id already exists
      QuerySnapshot snapshot = await firestore
          .collection('tbl_class_candidate')
          .where('student_id', isEqualTo: documentId)
          .where('election_id', isEqualTo: eid)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Document already exists, show an error message
        // _progressDialog.hide();
        Fluttertoast.showToast(
          msg: "You have already applied for this election",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } else {
        // No existing document found, proceed with adding a new document
        await firestore.collection('tbl_class_candidate').add({
          "student_id": documentId,
          "election_id": eid,
          "candidate_status": 0,
          "winner": '',
          "submission_date": formattedDate,
        });
        // _progressDialog.hide();
        Fluttertoast.showToast(
          msg: "Candidate Applied",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      // _progressDialog.hide();
      print('Error applying candidate: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromFirestore();
    cVoteCheck();
    cgVoteCheck();
    // _progressDialog = ProgressDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Election Dashboard',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      textAlign: TextAlign.center,
                      'Welcome to Election Dashboard',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Election Details: $eDetails',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Election Date: $eforDate',
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            'Nomination Last Date: $elastDate',
                            style: const TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        applyCandidate();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text('Apply for Election'),
                    ),
                    const SizedBox(height: 10),
                    if (cgVote) // Checking if eStatus equals 1
                      ElevatedButton(
                        // Creating an ElevatedButton widget
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClassVoting()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, // Text color
                          backgroundColor:
                              Colors.blue, // Button background color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15), // Button padding
                        ),
                        child: const Text(
                            'Apply for College Election'), // Text displayed inside the button
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ViewClassCandidate(eId: eid,)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text('View Candidates'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ViewResult(eId: eid,),));
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text('Class Election Results'),
                    ),
                    const SizedBox(height: 10),
                    if (eStatus == "1" &&
                        cVote == true) // Checking if eStatus equals 1
                      ElevatedButton(
                        // Creating an ElevatedButton widget
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClassVoting()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, // Text color
                          backgroundColor:
                              Colors.blue, // Button background color
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15), // Button padding
                        ),
                        child: const Text(
                            'Vote'), // Text displayed inside the button
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
