// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'manage_booking.dart'; // Import ManageBookingsPage
import 'view_patients.dart'; // Import ViewPatientsPage
import '../doctor_login.dart'; // Import LoginPage
import 'video_home_page.dart'; // Import VideoHomePage

class DoctorDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Dashboard'),
        actions: [
          IconButton(
            onPressed: () async {
              // Sign out logic
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DoctorLoginPage()),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ViewPatientsPage()),
                );
              },
              child: Text('View Patients'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageBookingsPage()),
                );
              },
              icon: Icon(Icons.calendar_today),
              label: Text('Manage Bookings'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VideoHomePage()),
                );
              },
              icon: Icon(Icons.video_call),
              label: Text('Start Video Call'),
            ),
          ],
        ),
      ),
    );
  }
}
