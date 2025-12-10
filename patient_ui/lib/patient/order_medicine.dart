// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cart_page.dart';

class OrderMedicinePage extends StatefulWidget {
  @override
  _OrderMedicinePageState createState() => _OrderMedicinePageState();
}

class _OrderMedicinePageState extends State<OrderMedicinePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> allMedicines = [];
  List<Map<String, dynamic>> filteredMedicines = [];
  List<String> documentIds = [];
  Map<String, int> quantities = {};

  @override
  void initState() {
    super.initState();
    _fetchMedicines();
  }

  // Fetch medicines from Firestore and store them in allMedicines, filteredMedicines, and documentIds
  void _fetchMedicines() {
    _firestore.collection('medicines').snapshots().listen((snapshot) {
      var medicines = snapshot.docs.map((doc) {
        return {
          "name": doc['name']?.toString() ?? '',
          "category": doc['category']?.toString() ?? '',
          "use": doc['use']?.toString() ?? '',
          "details": doc['details']?.toString() ?? '',
          "price": doc['price']?.toDouble() ?? 0.0,
        };
      }).toList();

      var ids = snapshot.docs.map((doc) => doc.id).toList();

      setState(() {
        allMedicines = medicines;
        filteredMedicines = medicines; // Initially, show all medicines
        documentIds = ids;
        for (var id in ids) {
          quantities[id] = 0; // Initialize quantity to 0 for all medicines
        }
      });
    });
  }

  // Function to filter medicines based on search query
  void _filterMedicines(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMedicines = allMedicines;
      } else {
        filteredMedicines = allMedicines.where((medicine) {
          return medicine['name']!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              medicine['category']!
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              medicine['use']!.toLowerCase().contains(query.toLowerCase()) ||
              medicine['price'].toString().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Medicines'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to CartPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartPage(
                    quantities: quantities,
                    medicines: allMedicines,
                    documentIds: documentIds,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: _filterMedicines,
              decoration: InputDecoration(
                labelText: 'Search by name, category, use, or price',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredMedicines.length,
                itemBuilder: (context, index) {
                  String docId = documentIds[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(filteredMedicines[index]['name']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Category: ${filteredMedicines[index]['category']}'),
                          Text('Use: ${filteredMedicines[index]['use']}'),
                          Text(
                              'Details: ${filteredMedicines[index]['details']}'),
                          Text('Price: ₹${filteredMedicines[index]['price']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              setState(() {
                                if (quantities[docId]! > 0) {
                                  quantities[docId] = quantities[docId]! - 1;
                                }
                              });
                            },
                          ),
                          Text(
                            quantities[docId].toString(),
                            style: TextStyle(fontSize: 18),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                quantities[docId] = quantities[docId]! + 1;
                              });
                            },
                          ),
                        ],
                      ),
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
