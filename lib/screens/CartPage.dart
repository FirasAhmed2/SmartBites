import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var recipe = snapshot.data!.docs[index];
              var recipeData = recipe.data() as Map<String, dynamic>;
              int quantity = recipeData['quantity'] ?? 1;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: recipeData['imageUrl'] != null
                      ? Image.network(recipeData['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.restaurant, size: 50, color: Colors.grey),
                  title: Text(recipeData['name'] ?? 'Unnamed Recipe'),
                  subtitle: Text('${recipeData['cookingTime'] ?? 'N/A'} mins'),
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
                                .update({'quantity': quantity - 1});
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
                              .update({'quantity': quantity + 1});
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
