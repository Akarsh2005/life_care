// ignore_for_file: avoid_print, use_build_context_synchronously, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../doctor/doctor_dashboard.dart';
import '../doctor/doctor_register.dart';

class DoctorLoginPage extends StatefulWidget {
  const DoctorLoginPage({super.key});

  @override
  State<DoctorLoginPage> createState() => _DoctorLoginPageState();
}

class _DoctorLoginPageState extends State<DoctorLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> loginDoctor() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      final userId = userCredential.user?.uid;

      if (userId != null) {
        final doctorDoc =
            await FirebaseFirestore.instance
                .collection('doctors')
                .doc(userId)
                .get();

        if (doctorDoc.exists) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DoctorDashboard()),
          );
        } else {
          FirebaseAuth.instance.signOut(); // Logout if not a doctor
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('Access Denied'),
                  content: Text('You are not registered as a doctor.'),
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
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        final userId = user.uid;
        final doctorDoc =
            await FirebaseFirestore.instance
                .collection('doctors')
                .doc(userId)
                .get();

        if (doctorDoc.exists) {
          // User is already registered as a doctor
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DoctorDashboard()),
          );
        } else {
          // User is not registered as a doctor, redirect to registration page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => DoctorRegisterPage(
                    name: googleUser.displayName ?? '',
                    email: googleUser.email,
                  ),
            ),
          );
        }
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Failed to sign in with Google. Please try again.'),
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
      appBar: AppBar(title: Text('Doctor Login')),
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
            ElevatedButton(onPressed: loginDoctor, child: Text('Sign In')),
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
                      builder: (context) => DoctorRegisterPage(),
                    ),
                  ),
              child: Text('Register as Doctor'),
            ),
          ],
        ),
      ),
    );
  }
}
