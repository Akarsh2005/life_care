// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewAppointmentPage extends StatefulWidget {
  @override
  _ViewAppointmentPageState createState() => _ViewAppointmentPageState();
}

class _ViewAppointmentPageState extends State<ViewAppointmentPage> {
  String selectedStatus = 'All'; // Default status filter ('All' to show all)

  // Function to fetch appointments based on selected status
  Stream<QuerySnapshot> _fetchAppointments() {
    final query = FirebaseFirestore.instance
        .collection('bookings')
        .where('patientId', isEqualTo: FirebaseAuth.instance.currentUser?.uid);

    // Add status filter if not 'All'
    if (selectedStatus != 'All') {
      return query.where('status', isEqualTo: selectedStatus).snapshots();
    } else {
      return query.snapshots(); // Return all appointments for 'All'
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Appointments'),
      ),
      body: Column(
        children: [
          // Dropdown to filter appointments by status
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: selectedStatus,
              items: [
                'All',
                'Pending',
                'Confirmed',
                'Completed',
                'Cancelled',
                'Rescheduled'
              ]
                  .map((status) => DropdownMenuItem<String>(
                        // Added 'Rescheduled' to the filter
                        value: status,
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
          ),

          // StreamBuilder to display appointments based on status
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _fetchAppointments(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      selectedStatus == 'All'
                          ? 'No appointments found.'
                          : 'No appointments found for $selectedStatus status.',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  );
                }

                final appointments = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment =
                        appointments[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.only(bottom: 16.0),
                      child: ListTile(
                        title:
                            Text(appointment['doctorName'] ?? 'Unknown Doctor'),
                        subtitle: Text(
                          'Specialty: ${appointment['doctorSpecialty'] ?? 'Unknown'}\n'
                          'Reason: ${appointment['reason'] ?? 'No reason'}\n'
                          'Date: ${appointment['appointmentDateTime'] != null ? appointment['appointmentDateTime'].toDate().toString() : 'Unknown'}',
                        ),
                        trailing: Text(
                          appointment['status'] ?? 'Unknown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: appointment['status'] == 'Completed'
                                ? Colors.green
                                : appointment['status'] == 'Pending'
                                    ? Colors.orange
                                    : appointment['status'] == 'Cancelled'
                                        ? Colors.red
                                        : appointment['status'] ==
                                                'Rescheduled' // Display Rescheduled status
                                            ? Colors.blue
                                            : Colors.blue,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
