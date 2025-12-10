// ignore_for_file: use_key_in_widget_constructors, avoid_types_as_parameter_names, avoid_print, prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'patient_dashboard.dart'; // Import PatientDashboard

class MedicinePaymentPage extends StatelessWidget {
  final String patientId;
  final String patientName;
  final List<Map<String, dynamic>> cartItems;

  const MedicinePaymentPage({
    required this.patientId,
    required this.patientName,
    required this.cartItems,
  });

  Future<void> _addPaymentToFirestore() async {
    try {
      // Add payment details to Firestore
      await FirebaseFirestore.instance.collection('payments').add({
        'patientId': patientId,
        'patientName': patientName,
        'cartItems': cartItems,
        'totalPrice': cartItems.fold<int>(
            0,
            (sum, item) =>
                sum + (item['total'] as int)), // Total price calculation
        'paymentStatus': 'Successful', // Payment status
        'paymentTime': Timestamp.now(),
      });

      // Add order to the "orders" collection with initial "medical processing" status
      await FirebaseFirestore.instance.collection('orders').add({
        'patient_id': patientId,
        'patient_name': patientName,
        'cartItems': cartItems,
        'totalPrice': cartItems.fold<int>(
            0, (sum, item) => sum + (item['total'] as int)), // Cast to int
        'timestamp': FieldValue.serverTimestamp(),
        'orderStatus': 'medical processing', // Initial order status
      });

      // Now update the order status to "payment successful"
      QuerySnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('patient_id', isEqualTo: patientId)
          .where('timestamp', isEqualTo: FieldValue.serverTimestamp())
          .get();

      if (orderSnapshot.docs.isNotEmpty) {
        // Update the first matching order's status
        await orderSnapshot.docs.first.reference.update({
          'orderStatus': 'payment successful',
        });
      }
    } catch (e) {
      print('Error adding payment details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                // Simulate payment success
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Payment successful!')),
                );

                // Save payment details to Firestore and add order status
                await _addPaymentToFirestore();

                // Navigate to PatientDashboard
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDashboard(),
                  ),
                  (route) => false,
                );
              },
              child: Text('Proceed with Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
