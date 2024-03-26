import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldpasswordController = TextEditingController(); 
  final TextEditingController _newpasswordController = TextEditingController(); 
  final TextEditingController _retypepasswordController = TextEditingController(); 
  void ChangePassword(){
    print(_oldpasswordController.text);
    print(_newpasswordController.text);
    print(_retypepasswordController.text);
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
            borderRadius: BorderRadius.circular(20.0)
          ),
          child: Column(
            children:[
              const SizedBox(
                height: 50,
              ),
              const Text('CHANGE PASSWORD?',style: TextStyle(fontSize: 20,fontStyle: FontStyle.italic,fontWeight: FontWeight.bold),),
              const SizedBox(
                height: 40,
              ),
        TextFormField(
          controller: _oldpasswordController,
          obscureText: true,
          decoration: const InputDecoration(
          hintText:'Enter Your old password'
        ),
        ),
         TextFormField(
          controller: _newpasswordController,
          obscureText: true,
          decoration: const InputDecoration(
          hintText:'Enter Your new password'
        ),
        ),
         TextFormField(
          controller: _retypepasswordController,
          obscureText: true,
          decoration: const InputDecoration(
          hintText:'Retype Your new password'
        ),
        ),
        ElevatedButton(onPressed: (){
          ChangePassword();
        },child:const Text('CHANGE'))
      ],
    ),
    ),
    ),
    );
  }
}
     