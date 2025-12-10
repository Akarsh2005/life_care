// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';

class StorePrescriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctor's Prescriptions"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Add functionality to upload a prescription
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Upload Prescription feature coming soon!')),
                );
              },
              child: Text('Upload Prescription'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Add functionality to view prescriptions
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('View Prescriptions feature coming soon!')),
                );
              },
              child: Text('View Prescriptions'),
            ),
          ],
        ),
      ),
    );
  }
}
