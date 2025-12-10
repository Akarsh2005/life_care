// ignore_for_file: use_key_in_widget_constructors, unused_element, avoid_types_as_parameter_names, avoid_print, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'medicine_payment.dart';

class CartPage extends StatelessWidget {
  final Map<String, int> quantities;
  final List<Map<String, dynamic>> medicines;
  final List<String> documentIds;

  const CartPage({
    required this.quantities,
    required this.medicines,
    required this.documentIds,
  });

  Future<void> _addOrderToFirestore(String patientId, String patientName,
      List<Map<String, dynamic>> cartItems) async {
    await FirebaseFirestore.instance.collection('orders').add({
      'patient_id': patientId,
      'patient_name': patientName,
      'cartItems': cartItems,
      'totalPrice': cartItems.fold<int>(
          0, (sum, item) => sum + (item['total'] as int)), // Cast to int
      'timestamp': FieldValue.serverTimestamp(),
      'orderStatus': 'medical processing', // Initial status
    });
  }

  // Fetch patient name from Firestore based on the patientId (uid)
  Future<String> _fetchPatientName(String patientId) async {
    try {
      DocumentSnapshot patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .get();
      if (patientDoc.exists) {
        return patientDoc['name'] ??
            'Anonymous'; // Return 'Anonymous' if the name field is not found
      } else {
        return 'Anonymous'; // Return 'Anonymous' if the patient document doesn't exist
      }
    } catch (e) {
      print('Error fetching patient name: $e');
      return 'Anonymous';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = medicines
        .asMap()
        .entries
        .where((entry) => quantities[documentIds[entry.key]]! > 0)
        .map((entry) {
      final index = entry.key;
      final medicine = entry.value;
      final quantity = quantities[documentIds[index]]!;
      return {
        'name': medicine['name'],
        'price': medicine['price'],
        'quantity': quantity,
        'total': (medicine['price'] * quantity)
            .toInt(), // Ensure total is cast to int
      };
    }).toList();

    // Fetch the patientId from Firebase Auth
    String patientId = FirebaseAuth.instance.currentUser?.uid ?? 'Unknown';

    return FutureBuilder<String>(
      future:
          _fetchPatientName(patientId), // Fetch the patient name asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching patient name'));
        } else if (snapshot.hasData) {
          String patientName = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              title: Text('Your Cart'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cartItems.length,
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(item['name']),
                            subtitle: Text('Quantity: ${item['quantity']}'),
                            trailing: Text('₹${item['total']}'),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Total Price: ₹${cartItems.fold<int>(0, (sum, item) => sum + (item['total'] as int))}', // Cast total to int
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      // Pass the patient details and cart items to the MedicinePaymentPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MedicinePaymentPage(
                            patientId: patientId,
                            patientName: patientName,
                            cartItems: cartItems,
                          ),
                        ),
                      );
                    },
                    child: Text('Checkout'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }
}
