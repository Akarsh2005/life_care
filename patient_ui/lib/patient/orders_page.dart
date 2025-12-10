// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  // Fetch orders from Firestore
  void _fetchOrders() {
    _firestore.collection('orders').snapshots().listen((snapshot) {
      var fetchedOrders = snapshot.docs.map((doc) {
        return {
          'patient_name': doc['patient_name'],
          'totalPrice': doc['totalPrice'],
          'timestamp': doc['timestamp'],
          'cartItems': doc['cartItems'],
          'orderStatus': doc['orderStatus'], // Fetch order status
        };
      }).toList();

      setState(() {
        orders = fetchedOrders;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(order['patient_name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total: ₹${order['totalPrice']}'),
                    Text('Order Date: ${order['timestamp'].toDate()}'),
                    Text(
                        'Status: ${order['orderStatus']}'), // Display order status
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
