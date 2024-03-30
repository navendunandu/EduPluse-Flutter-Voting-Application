import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import the cloud_firestore package

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({Key? key}) : super(key: key);

  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final TextEditingController _complaintController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitComplaint() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      final userId = user?.uid;
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('tbl_studentregister')
          .where('Student_id', isEqualTo: userId)
          .get();
      String documentId = studentSnapshot.docs.first.id;
      if (userId != null) {
        final complaintContent = _complaintController.text.trim();
        try {
          // Add the complaint to Firestore
          await FirebaseFirestore.instance.collection('tbl_complaint').add({
            'complaint_title':_titleController.text.trim(),
            'student_id': documentId,
            'complaint_content': complaintContent,
            'date': FieldValue.serverTimestamp(),
            'reply':"",
            'status':0,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint submitted successfully.'),
            ),
          );
          _complaintController.clear();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting complaint: $e'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Complaint'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter complaint title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Please enter a complaint';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _complaintController,
                maxLines: null,
                minLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter your complaint',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Please enter a complaint';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitComplaint,
                child: const Text('Submit Complaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}