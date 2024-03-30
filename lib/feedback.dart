import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final feedbackContent = _feedbackController.text.trim();
        try {
          await FirebaseFirestore.instance.collection('tbl_feedback').add({
            'feedback': feedbackContent,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Feedback submitted successfully.'),
            ),
          );
          _feedbackController.clear();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error submitting feedback: $e'),
            ),
          );
        }
      } else {
        // Handle the case where the user is not logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to submit feedback.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _feedbackController,
                maxLines: null,
                minLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Enter your feedback',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}

