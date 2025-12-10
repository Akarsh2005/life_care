// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';

class MedicalHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical History'),
      ),
      body: Center(
        child: Text(
          'Medical History Page',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}
