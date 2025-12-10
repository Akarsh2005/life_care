// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view_history.dart';
import 'reschedule_page.dart';
import 'set_availability.dart';
import 'update_status.dart';

class ManageBookingsPage extends StatefulWidget {
  @override
  _ManageBookingsPageState createState() => _ManageBookingsPageState();
}

class _ManageBookingsPageState extends State<ManageBookingsPage> {
  String searchQuery = '';
  final String doctorIdField = 'doctorId';
  final String patientNameField = 'patientName';
  final String statusField = 'status';

  // Function to fetch bookings from Firestore
  Stream<QuerySnapshot> _fetchBookings() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Return an empty stream if the user is not logged in
      return Stream.empty();
    }

    try {
      // Fetch bookings where doctorId matches the logged-in user's UID
      return FirebaseFirestore.instance
          .collection('bookings')
          .where('doctorDocId',
              isEqualTo: user.uid) // Ensure 'doctorDocId' is correct
          .snapshots();
    } catch (e) {
      // Handle any Firestore errors gracefully
      debugPrint('Error fetching bookings: $e');
      return Stream.empty();
    }
  }

  void _handleMenuSelection(
      String value, String patientName, String bookingId) {
    switch (value) {
      case 'View History':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewHistoryPage(patientName: patientName),
          ),
        );
        break;
      case 'Reschedule Appointment':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReschedulePage(bookingId: bookingId),
          ),
        );
        break;
      case 'Set Availability':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SetAvailabilityPage(),
          ),
        );
        break;
      case 'Update Status':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateStatusPage(bookingId: bookingId),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bookings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Bookings',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _fetchBookings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error fetching bookings. Please try again later.',
                        style: TextStyle(fontSize: 16.0, color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        'No bookings found.',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    );
                  }

                  // Filter bookings based on search query
                  final bookings = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final patientName =
                        (data[patientNameField] ?? '').toLowerCase();
                    return patientName.contains(searchQuery);
                  }).toList();

                  // Show filtered bookings
                  if (bookings.isEmpty) {
                    return Center(
                      child: Text(
                        'No bookings match your search.',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {}); // Trigger a UI rebuild
                    },
                    child: ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        final booking =
                            bookings[index].data() as Map<String, dynamic>;
                        final patientName =
                            booking[patientNameField] ?? 'Unknown';
                        final status = booking[statusField] ?? 'Unknown';
                        final bookingId = bookings[index].id;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text(patientName),
                            subtitle: Text('Status: $status'),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) => _handleMenuSelection(
                                  value, patientName, bookingId),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'View History',
                                  child: Text('View History'),
                                ),
                                PopupMenuItem(
                                  value: 'Reschedule Appointment',
                                  child: Text('Reschedule Appointment'),
                                ),
                                PopupMenuItem(
                                  value: 'Set Availability',
                                  child: Text('Set Availability'),
                                ),
                                PopupMenuItem(
                                  value: 'Update Status',
                                  child: Text('Update Status'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
