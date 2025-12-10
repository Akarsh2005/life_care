// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, use_build_context_synchronously, unused_import, use_super_parameters

import 'package:doctor_ui/doctor/doctor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../doctor_login.dart';

class DoctorRegisterPage extends StatefulWidget {
  final String? name;
  final String? email;

  const DoctorRegisterPage({this.name, this.email, Key? key}) : super(key: key);

  @override
  State<DoctorRegisterPage> createState() => _DoctorRegisterPageState();
}

class _DoctorRegisterPageState extends State<DoctorRegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final specializationController = TextEditingController();
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill the form with Google Sign-In data if available
    if (widget.name != null) nameController.text = widget.name!;
    if (widget.email != null) emailController.text = widget.email!;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    specializationController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> registerDoctor() async {
    if (formKey.currentState?.validate() ?? false) {
      try {
        final User? currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
          // If the user is not signed in, create a new account with email/password
          final userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
              );

          // Store additional user data in Firestore
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(userCredential.user?.uid)
              .set({
                'name': nameController.text.trim(),
                'email': emailController.text.trim(),
                'specialization': specializationController.text.trim(),
                'phone': phoneController.text.trim(),
              });
        } else {
          // If the user is already signed in (e.g., via Google), update their profile in Firestore
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(currentUser.uid)
              .set({
                'name': nameController.text.trim(),
                'email': emailController.text.trim(),
                'specialization': specializationController.text.trim(),
                'phone': phoneController.text.trim(),
              });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Doctor Registered Successfully')),
        );

        // Navigate to the dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => DoctorDashboard()),
          (route) => false,
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Registration Failed')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Doctor Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Name is required' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Email is required' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  } else if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: specializationController,
                decoration: InputDecoration(
                  labelText: 'Specialization',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Specialization is required'
                            : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value?.isEmpty ?? true
                            ? 'Phone number is required'
                            : null,
              ),
              SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: registerDoctor,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
