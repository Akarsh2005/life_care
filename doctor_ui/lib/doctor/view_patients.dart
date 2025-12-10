// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';

class ViewPatientsPage extends StatelessWidget {
  final List<Map<String, String>> patients = [
    {"name": "Patient 1", "details": "Reason: Headache"},
    {"name": "Patient 2", "details": "Reason: Fever"},
    {"name": "Patient 3", "details": "Reason: Back Pain"},
    {"name": "Patient 4", "details": "Reason: Diabetes Checkup"},
    {"name": "Patient 5", "details": "Reason: Follow-up"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Patients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                leading: Icon(Icons.person),
                title: Text(patients[index]["name"]!),
                subtitle: Text(patients[index]["details"]!),
                trailing: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Patient Details'),
                        content: Text('${patients[index]["details"]}'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('View'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
