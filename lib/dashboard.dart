import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupulse/election_dashboard.dart';
import 'package:edupulse/feedback.dart';
import 'package:edupulse/login.dart';
import 'package:edupulse/my_complaint.dart';
import 'package:edupulse/my_profile.dart';
import 'package:edupulse/post_complaint.dart';
import 'package:edupulse/union_members.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String name = 'Loading...';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    getData();
  }
  
  void logout(){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Login(),));
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
        name = querySnapshot.docs.first['Student_name'];
      });
    } else {
      setState(() {
        name = 'Error Loading Data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EDUPULSE'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 50,
            ),
            ListTile(
              title: const Text('My Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyProfile()),
                );
              },
            ),
            ListTile(
              title: const Text('Complaint'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComplaintScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('Feedback'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),
            ListTile(
              title: const Text('My Complaints'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ComplaintsPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Logout'),
              onTap: () {
                _auth.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login(),));
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                  image:
                      DecorationImage(image: AssetImage("assets/voter.jpg"),fit: BoxFit.contain)),
              height: 350,
            ),
            const Center(
              child: Text(
                'Hello,',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ElectionDashboard(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                height: 60,
                width: MediaQuery.of(context).size.width * 0.8,
                child: const Center(
                  child: Text(
                    'Election',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyProfile(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                height: 60,
                width: MediaQuery.of(context).size.width * 0.8,
                child: const Center(
                  child: Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UnionMembers(),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Colors.blueAccent, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                height: 60,
                width: MediaQuery.of(context).size.width * 0.8,
                child: const Center(
                  child: Text(
                    'Union Members',
                    style: TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
