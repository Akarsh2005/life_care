// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateStatusPage extends StatefulWidget {
  final String bookingId;

  UpdateStatusPage({required this.bookingId});

  @override
  _UpdateStatusPageState createState() => _UpdateStatusPageState();
}

class _UpdateStatusPageState extends State<UpdateStatusPage> {
  String selectedStatus = 'Pending'; // Default status
  bool isLoading = false; // To manage loading state

  // Function to update booking status in Firestore
  Future<void> _updateStatusInDatabase() async {
    setState(() {
      isLoading = true; // Show a loading indicator
    });

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId) // Use the bookingId to find the document
          .update({
        'status': selectedStatus, // Update the 'status' field
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated successfully!')),
      );

      Navigator.pop(context); // Go back to the previous screen
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false; // Hide the loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Booking Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select a new status for this booking.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            DropdownButton<String>(
              value: selectedStatus,
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
              items: ['Pending', 'Confirmed', 'Completed', 'Cancelled']
                  .map((status) => DropdownMenuItem<String>(
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16.0),
            isLoading
                ? Center(
                    child: CircularProgressIndicator(), // Show loading spinner
                  )
                : ElevatedButton(
                    onPressed: _updateStatusInDatabase,
                    child: Text('Update Status'),
                  ),
          ],
        ),
      ),
    );
  }
}
