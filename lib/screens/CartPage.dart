import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/CheckoutPage.dart'; // Import Checkout Page

class CartPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Cart"),
        backgroundColor: Colors.blue[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(_auth.currentUser?.uid).collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Your cart is empty"));
          }

          double totalPrice = 0.0;
          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            int quantity = data['quantity'] ?? 1;
            int itemTotal = 200 * quantity; // Each recipe is fixed at $200
            totalPrice += itemTotal;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var recipe = snapshot.data!.docs[index];
                    var recipeData = recipe.data() as Map<String, dynamic>;
                    int quantity = recipeData['quantity'] ?? 1;
                    int itemTotal = 200 * quantity; // Each recipe is $200

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: recipeData['imageUrl'] != null
                            ? Image.network(recipeData['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                            : Icon(Icons.restaurant, size: 50, color: Colors.grey),
                        title: Text(recipeData['name'] ?? 'Unnamed Recipe'),
                        subtitle: Text("\$${itemTotal.toStringAsFixed(2)} (${quantity} x \$200)"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () async {
                                if (quantity > 1) {
                                  await _firestore
                                      .collection('users')
                                      .doc(_auth.currentUser?.uid)
                                      .collection('cart')
                                      .doc(recipe.id)
                                      .update({
                                    'quantity': quantity - 1,
                                    'price': (quantity - 1) * 200, // Update price based on new quantity
                                  });
                                } else {
                                  await _firestore
                                      .collection('users')
                                      .doc(_auth.currentUser?.uid)
                                      .collection('cart')
                                      .doc(recipe.id)
                                      .delete();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(content: Text("${recipeData['name']} removed from cart")));
                                }
                              },
                            ),
                            Text('$quantity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: Colors.green),
                              onPressed: () async {
                                await _firestore
                                    .collection('users')
                                    .doc(_auth.currentUser?.uid)
                                    .collection('cart')
                                    .doc(recipe.id)
                                    .update({
                                  'quantity': quantity + 1,
                                  'price': (quantity + 1) * 200, // Update price based on new quantity
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
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("\$${totalPrice.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[700])),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CheckoutPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Text("Proceed to Checkout",
                            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
