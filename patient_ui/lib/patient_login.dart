// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../patient/patient_dashboard.dart';
import '../patient/patient_register.dart';

class PatientLoginPage extends StatefulWidget {
  const PatientLoginPage({super.key});

  @override
  State<PatientLoginPage> createState() => _PatientLoginPageState();
}

class _PatientLoginPageState extends State<PatientLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleSignIn googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginPatient() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final userId = userCredential.user?.uid;

      if (userId != null) {
        final patientDoc =
            await FirebaseFirestore.instance
                .collection('patients')
                .doc(userId)
                .get();

        if (patientDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PatientDashboard()),
          );
        } else {
          FirebaseAuth.instance.signOut(); // Logout if not a patient
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Access Denied'),
                  content: Text('You are not registered as a patient.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('OK'),
                    ),
                  ],
                ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Error'),
              content: Text(e.message ?? 'An unknown error occurred.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential authResult = await FirebaseAuth.instance
            .signInWithCredential(credential);
        final User? user = authResult.user;

        if (user != null) {
          final userId = user.uid;
          final patientDoc =
              await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(userId)
                  .get();

          if (!patientDoc.exists) {
            await FirebaseFirestore.instance
                .collection('patients')
                .doc(userId)
                .set({'name': user.displayName, 'email': user.email});
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => PatientDashboard()),
          );
        }
      }
    } catch (e) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Failed to sign in with Google.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Patient Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            ElevatedButton(onPressed: loginPatient, child: Text('Sign In')),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: signInWithGoogle,
              child: Text('Sign In with Google'),
            ),
            SizedBox(height: 16.0),
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientRegisterPage(),
                    ),
                  ),
              child: Text('Register as Patient'),
            ),
          ],
        ),
      ),
    );
  }
}
