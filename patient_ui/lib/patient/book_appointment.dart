// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously, unused_import, unnecessary_cast

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'payment_page.dart'; // Import the payment page

class BookAppointmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for doctors, specialties, or clinics',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No doctors found :('),
                    );
                  }

                  final doctors = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor =
                          doctors[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: EdgeInsets.only(bottom: 16.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(
                              doctor['image'] ?? '',
                            ),
                          ),
                          title: Text(doctor['name'] ?? 'Unknown Doctor'),
                          subtitle: Text(
                              'Specialty: ${doctor['specialty'] ?? 'Unknown'}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              final reasonController = TextEditingController();
                              DateTime? selectedDateTime;

                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return StatefulBuilder(
                                    builder: (context, setState) {
                                      return AlertDialog(
                                        title:
                                            Text('${doctor['name']} - Details'),
                                        content: SingleChildScrollView(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Name: ${doctor['name']}\n'
                                                'Specialty: ${doctor['specialty']}',
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              ),
                                              SizedBox(height: 16.0),
                                              TextField(
                                                controller: reasonController,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Reason for Appointment',
                                                  border: OutlineInputBorder(),
                                                ),
                                                maxLines: 3,
                                              ),
                                              SizedBox(height: 16.0),
                                              Text(
                                                'Select Date and Time:',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(height: 8.0),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  final date =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime(2101),
                                                  );
                                                  if (date != null) {
                                                    final time =
                                                        await showTimePicker(
                                                      context: context,
                                                      initialTime:
                                                          TimeOfDay.now(),
                                                    );
                                                    if (time != null) {
                                                      setState(() {
                                                        selectedDateTime =
                                                            DateTime(
                                                          date.year,
                                                          date.month,
                                                          date.day,
                                                          time.hour,
                                                          time.minute,
                                                        );
                                                      });
                                                    }
                                                  }
                                                },
                                                child: Text('Pick Date & Time'),
                                              ),
                                              if (selectedDateTime != null)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8.0),
                                                  child: Text(
                                                    'Selected: ${selectedDateTime.toString()}',
                                                    style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.green),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Close'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (reasonController
                                                      .text.isEmpty ||
                                                  selectedDateTime == null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Please provide all details!'),
                                                  ),
                                                );
                                                return;
                                              }

                                              // Navigate to PaymentPage with details and docId
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PaymentPage(
                                                    doctorDocId: doctors[index]
                                                        .id, // Pass docId
                                                    doctorName:
                                                        doctor['name'] ?? '',
                                                    doctorSpecialty:
                                                        doctor['specialty'] ??
                                                            '',
                                                    reason:
                                                        reasonController.text,
                                                    appointmentDateTime:
                                                        selectedDateTime!,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text('Proceed to Payment'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: Text('View'),
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
      ),
    );
  }
}
