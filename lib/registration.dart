// ignore_for_file: unnecessary_null_comparison, avoid_print, use_build_context_synchronously, avoid_function_literals_in_foreach_calls

import 'dart:io';
import 'package:edupulse/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class Registration extends StatefulWidget {
  const Registration({Key? key}) : super(key: key);

  @override
  State<Registration> createState() => RegistrationState();
}

class RegistrationState extends State<Registration> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _adminoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  XFile? _selectedImage;
  String? _imageUrl;
  String? _selectedDept;
  String? _selectedCourse;
  String? _selectedYear;
  List<Map<String, dynamic>> deptList = [];
  List<Map<String, dynamic>> courseList = [];
  List<Map<String, dynamic>> yearList = [];
  String? filePath;
  late ProgressDialog _progressDialog;
  @override
  void initState() {
    super.initState();
    _progressDialog = ProgressDialog(context);

    fetchDeptData();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          filePath = result.files.single.path;
        });
      } else {
        print('File picking canceled.');
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> register() async {
    try {
      _progressDialog.show();
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (userCredential != null) {
        await _storeUserData(userCredential.user!.uid);
        Fluttertoast.showToast(
          msg: "Registration Successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        _progressDialog.hide();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } catch (e) {
      _progressDialog.hide();
      Fluttertoast.showToast(
        msg: "Registration Failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      print("Error registering user: $e");
    }
  }

  Future<void> _storeUserData(String userId) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('tbl_studentregister').add({
        'Student_name': _nameController.text,
        'Student_email': _emailController.text,
        'Student_contact': _contactController.text,
        'Student_gender': selectedGender,
        'Student_address': _addressController.text,
        'Student_password': _passwordController.text,
        'course_id': _selectedCourse,
        'year_id': _selectedYear,
        'Student_id': userId,
        'student_status': 0,
      });

      await _uploadImage(userId);
    } catch (e) {
      print("Error storing user data: $e");
    }
  }

  Future<void> _uploadImage(String userId) async {
    try {
      if (_selectedImage != null) {
        Reference ref =
            FirebaseStorage.instance.ref().child('Student_Photo/$userId.jpg');
        UploadTask uploadTask = ref.putFile(File(_selectedImage!.path));
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

        String imageUrl = await taskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('tbl_studentregister')
            .where('Student_id', isEqualTo: userId)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.update({
              'Student_photo': imageUrl,
            });
          });
        }).catchError((error) {
          print("Error updating user: $error");
        });
      }

      if (filePath != null) {
        String fileName = filePath!.split('/').last;

        Reference fileRef = FirebaseStorage.instance
            .ref()
            .child('Student_Files/$userId/$fileName');
        UploadTask fileUploadTask = fileRef.putFile(File(filePath!));
        TaskSnapshot fileTaskSnapshot =
            await fileUploadTask.whenComplete(() => null);

        String fileUrl = await fileTaskSnapshot.ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('tbl_studentregister')
            .where('Student_id', isEqualTo: userId)
            .get()
            .then((QuerySnapshot querySnapshot) {
          querySnapshot.docs.forEach((doc) {
            doc.reference.update({
              'Student_file': fileUrl,
            });
          });
        }).catchError((error) {
          print("Error updating user: $error");
        });
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  Future<void> fetchDeptData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('tbl_department').get();

      List<Map<String, dynamic>> dept = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['department_name'].toString(),
              })
          .toList();

      setState(() {
        deptList = dept;
      });
    } catch (e) {
      print('Error fetching department data: $e');
    }
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('tbl_year').get();

      List<Map<String, dynamic>> year = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['year_name'].toString(),
              })
          .toList();

      setState(() {
        yearList = year;
      });
    } catch (e) {
      print('Error fetching year data: $e');
    }
  }

  Future<void> fetchCourseData(id) async {
    try {

      QuerySnapshot<Map<String, dynamic>> querySnapshot1 =
          await FirebaseFirestore.instance
              .collection('tbl_course')
              .where('department_id', isEqualTo: id)
              .get();

      List<Map<String, dynamic>> dept1 = querySnapshot1.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['course_name'].toString(),
              })
          .toList();

      setState(() {
        courseList = dept1;
      });
    } catch (e) {
      print('Error fetching course data: $e');
    }
  }

  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EduPulse'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xff4c505b),
                        backgroundImage: _selectedImage != null
                            ? FileImage(File(_selectedImage!.path))
                            : _imageUrl != null
                                ? NetworkImage(_imageUrl!)
                                : const AssetImage('assets/dummy450x450.jpg')
                                    as ImageProvider,
                        child: _selectedImage == null && _imageUrl == null
                            ? const Icon(
                                Icons.add,
                                size: 40,
                                color: Color.fromARGB(255, 41, 39, 39),
                              )
                            : null,
                      ),
                      if (_selectedImage != null || _imageUrl != null)
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _buildIconTextField(Icons.person, _nameController, 'Name'),
              const SizedBox(height: 10),
              _buildIconTextField(Icons.email, _emailController, 'Email'),
              const SizedBox(height: 10),
              _buildIconTextField(Icons.phone, _contactController, 'Contact'),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Gender: ',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: Colors.blue,
                        value: 'Male',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      const Text('Male')
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: Colors.blue,
                        value: 'Female',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      const Text('Female')
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        activeColor: Colors.blue,
                        value: 'Others',
                        groupValue: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value!;
                          });
                        },
                      ),
                      const Text('Others')
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildIconTextField(Icons.home, _addressController, 'Address',
                  multiline: true),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedDept,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school),
                  hintText: 'Select Department',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
                onChanged: (String? newValue) {
                  fetchCourseData(newValue);
                  setState(() {
                    _selectedDept = newValue;
                  });
                },
                isExpanded: true,
                items: deptList.map<DropdownMenuItem<String>>(
                  (Map<String, dynamic> department) {
                    return DropdownMenuItem<String>(
                      value: department['id'],
                      child: Text(department['name']),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedCourse,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school),
                  hintText: "Select Course",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCourse = newValue;
                  });
                },
                isExpanded: true,
                items: courseList.map<DropdownMenuItem<String>>(
                  (Map<String, dynamic> course) {
                    return DropdownMenuItem<String>(
                      value: course['id'],
                      child: Text(course['name']),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedYear,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school),
                  hintText: "Select Year",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                    ),
                  ),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedYear = newValue;
                  });
                },
                isExpanded: true,
                items: yearList.map<DropdownMenuItem<String>>(
                  (Map<String, dynamic> year) {
                    return DropdownMenuItem<String>(
                      value: year['id'],
                      child: Text(year['name']),
                    );
                  },
                ).toList(),
              ),
              const SizedBox(height: 10),
              _buildIconTextField(
                  Icons.school, _adminoController, 'Admission Number'),
              const SizedBox(height: 10),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pickFile,
                          child: const Text('Upload File'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (filePath != null)
                    Text(
                      'Selected File: $filePath',
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _buildIconTextField(
                  Icons.security, _passwordController, 'Password',
                  obscureText: true),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: register,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconTextField(
      IconData icon, TextEditingController controller, String labelText,
      {bool obscureText = false, bool multiline = false}) {
    return TextFormField(
      maxLines: multiline ? null : 1,
      keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

}

