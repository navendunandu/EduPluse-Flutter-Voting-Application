import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edupulse/dashboard.dart';
import 'package:edupulse/forgot_password.dart';
import 'package:edupulse/registration.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:edupulse/dashboard.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late ProgressDialog _progressDialog;
  @override
  void initState() {
    super.initState();
    _progressDialog = ProgressDialog(context);
    // Call a function to fetch district data when the widget is created
  }

  Future<int?> fetchStudentStatus(String studentId) async {
    try {
      print('student id: $studentId');
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('tbl_studentregister')
              .where('Student_id', isEqualTo: studentId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming 'student_status' is a String field, adjust accordingly
        return querySnapshot.docs.first['student_status'] as int?;
      } else {
        print('No document found with Student_id $studentId.');
        return null;
      }
    } catch (e) {
      print('Error fetching student status: $e');
      return null;
    }
  }

  Future<void> login() async {
    print(_emailController.text);
    print(_passwordController.text);
    try {
      _progressDialog.show();

      final FirebaseAuth auth = FirebaseAuth.instance;
      final UserCredential userCredential =
          await auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print(userCredential.user?.uid);

      String? studentId = userCredential.user?.uid;
      if (studentId != null) {
        int? studentStatus = await fetchStudentStatus(studentId);
        print('Student Status: $studentStatus');
        if (studentStatus != null) {
          _progressDialog.hide();

          // Use studentStatus as needed
          print('Student Status: $studentStatus');
          if (studentStatus == 0) {
            Fluttertoast.showToast(
              msg: 'Account not verified',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          } else if (studentStatus == 2) {
            Fluttertoast.showToast(
              msg: 'Account Rejected',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white,
            );
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Dashboard(),
                ));
          }
        } else {
          _progressDialog.hide();

          print('Failed to fetch student status.');
        }
      }
    } catch (e) {
      _progressDialog.hide();

      // Handle login failure and show an error toast.
      String errorMessage = 'Login failed';

      if (e is FirebaseAuthException) {
        errorMessage = e.code;
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          height: 500,
          width: 500,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.0)),
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              const Text(
                'Login',
                style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 40,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(hintText: 'Enter Email'),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Enter Password'),
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPassword(),
                        ));
                  },
                  child: const Text('Forgot Password?')),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    login();
                  },
                  child: const Text('Login')),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Registration(),
                        ));
                  },
                  child: const Text('Create an account?'))
            ],
          ),
        ),
      ),
    );
  }
}
    // void gotodashboard() {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => const Dashboard(),));
// }
      