// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_constructors_in_immutables, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReschedulePage extends StatefulWidget {
  final String bookingId;

  ReschedulePage({required this.bookingId});

  @override
  _ReschedulePageState createState() => _ReschedulePageState();
}

class _ReschedulePageState extends State<ReschedulePage> {
  DateTime? selectedDateTime;

  // Function to check doctor availability
  Future<bool> isDoctorAvailable(DateTime selectedDateTime) async {
    // Example: Check if doctor is available by querying Firestore bookings
    final bookingsRef = FirebaseFirestore.instance.collection('bookings');
    final querySnapshot = await bookingsRef
        .where('appointmentDateTime', isEqualTo: selectedDateTime)
        .get();

    // If there are existing bookings at this time, doctor is unavailable
    return querySnapshot.docs.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reschedule Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select a new date and time for the appointment.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    final selectedDate = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );

                    // Check if doctor is available at the selected time
                    final isAvailable = await isDoctorAvailable(selectedDate);
                    if (isAvailable) {
                      setState(() {
                        selectedDateTime = selectedDate;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Doctor is unavailable at this time. Please select another time.')),
                      );
                    }
                  }
                }
              },
              child: Text('Pick New Date & Time'),
            ),
            if (selectedDateTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'New Appointment: ${selectedDateTime.toString()}',
                  style: TextStyle(fontSize: 14.0, color: Colors.green),
                ),
              ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                // Update the booking in Firestore with the new date
                if (selectedDateTime != null) {
                  final bookingsRef =
                      FirebaseFirestore.instance.collection('bookings');
                  await bookingsRef.doc(widget.bookingId).update({
                    'appointmentDateTime':
                        selectedDateTime, // Field updated to appointmentDateTime
                    'status': 'Rescheduled', // Optionally update the status
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Appointment rescheduled successfully!')),
                  );
                  Navigator.pop(context); // Go back to the previous screen
                }
              },
              child: Text('Reschedule Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
