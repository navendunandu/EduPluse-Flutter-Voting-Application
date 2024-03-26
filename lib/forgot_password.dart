import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  void forgotPassword() {
    print(_emailController.text);
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
                'FORGOT PASSWORD?',
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
                decoration: const InputDecoration(hintText: 'Enter Your Email'),
              ),
              ElevatedButton(
                  onPressed: () {
                    forgotPassword();
                  },
                  child: const Text('Send Link'))
            ],
          ),
        ),
      ),
    );
  }
}
