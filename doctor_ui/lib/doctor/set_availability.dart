// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

class SetAvailabilityPage extends StatefulWidget {
  @override
  _SetAvailabilityPageState createState() => _SetAvailabilityPageState();
}

class _SetAvailabilityPageState extends State<SetAvailabilityPage> {
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Availability'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select your working hours.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    selectedStartTime = time;
                  });
                }
              },
              child: Text('Pick Start Time'),
            ),
            if (selectedStartTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Start Time: ${selectedStartTime!.format(context)}',
                  style: TextStyle(fontSize: 14.0, color: Colors.green),
                ),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    selectedEndTime = time;
                  });
                }
              },
              child: Text('Pick End Time'),
            ),
            if (selectedEndTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'End Time: ${selectedEndTime!.format(context)}',
                  style: TextStyle(fontSize: 14.0, color: Colors.green),
                ),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Save the selected working hours in Firestore
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Availability updated successfully!')),
                );
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('Save Availability'),
            ),
          ],
        ),
      ),
    );
  }
}
