// patient_dashboard.dart
// ignore_for_file: use_key_in_widget_constructors, use_build_context_synchronously, avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'book_appointment.dart';
import 'view_appointment.dart';
import 'profile.dart';
import 'medical_history.dart';
import 'store_prescription.dart';
import 'order_medicine.dart';
import '../patient_login.dart';
import 'orders_page.dart';
import 'nearbypharmacy.dart';
import 'video_home_page.dart'; // Import the VideoHomePage

class PatientDashboard extends StatelessWidget {
  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientLoginPage()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome Back!'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              signOut(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookAppointmentPage(),
                  ),
                );
              },
              child: Text('Book Appointment'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewAppointmentPage(),
                  ),
                );
              },
              child: Text('View Appointments'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Text('Update Profile'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MedicalHistoryPage()),
                );
              },
              child: Text('Medical History'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StorePrescriptionPage(),
                  ),
                );
              },
              child: Text("Store Doctor's Prescription"),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrderMedicinePage()),
                );
              },
              child: Text('Order Medicines'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrdersPage(),
                  ),
                );
              },
              child: Text('Your Orders'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NearbyPharmacy(),
                  ),
                );
              },
              child: Text('Nearby Pharmacy'),
            ),
            SizedBox(height: 16.0),
            // Add Video Call Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoHomePage(),
                  ),
                );
              },
              child: Text('Video Call with Doctor'),
            ),
          ],
        ),
      ),
    );
  }
}