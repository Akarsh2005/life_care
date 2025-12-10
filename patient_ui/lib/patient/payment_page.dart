// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors, use_build_context_synchronously, avoid_print
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'patient_dashboard.dart'; // Import PatientDashboard

class PaymentPage extends StatelessWidget {
  final String doctorDocId; // Add this to hold the doctor's document ID
  final String doctorName;
  final String doctorSpecialty;
  final String reason;
  final DateTime appointmentDateTime;

  PaymentPage({
    required this.doctorDocId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.reason,
    required this.appointmentDateTime,
  });

  Future<String> _getPatientName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final doc = await FirebaseFirestore.instance
            .collection('patients')
            .doc(uid)
            .get();
        return doc.data()?['name'] ?? 'Unknown Patient';
      }
    } catch (e) {
      print('Error fetching patient name: $e');
    }
    return 'Unknown Patient';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment for Video Call'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'You are booking a video call with Dr. $doctorName',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 24.0),
            Text(
              'Please complete the payment to confirm the booking.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                // Simulate payment success
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment successful!')),
                );

                // Fetch patient name
                final patientName = await _getPatientName();

                // Save booking details to Firestore
                try {
                  await FirebaseFirestore.instance.collection('bookings').add({
                    'doctorDocId': doctorDocId, // Save the doctorDocId here
                    'doctorName': doctorName,
                    'doctorSpecialty': doctorSpecialty,
                    'patientId': FirebaseAuth.instance.currentUser?.uid ?? '',
                    'patientName': patientName, // Store patient name
                    'reason': reason,
                    'appointmentDateTime': appointmentDateTime,
                    'status': 'Pending',
                    'createdAt': Timestamp.now(),
                  });

                  // Navigate to PatientDashboard
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDashboard(),
                    ),
                    (route) => false,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Failed to confirm booking. Please try again later.'),
                    ),
                  );
                }
              },
              child: Text('Proceed with Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
