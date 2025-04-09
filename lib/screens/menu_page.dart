import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myapp/screens/CartPage.dart';
import 'package:myapp/screens/RecipeDetailsPage.dart';


class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                automaticallyImplyLeading: false,
                expandedHeight: 140.0,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 20),
                        child: Text(
                          'My Menu',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight
                              .bold, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Text(
                        "Save your favorite meals and plan your week",
                        style: TextStyle(
                            fontSize: 14, color: Colors.white.withOpacity(0.9)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_auth.currentUser?.uid)
                    .collection('recipes')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                        child: Center(child: Text('Something went wrong')));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.restaurant_menu, size: 64,
                                  color: Colors.grey[400]),
                              SizedBox(height: 16),
                              Text('No recipes yet',
                                  style: TextStyle(fontSize: 18,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500)),
                              SizedBox(height: 8),
                              Text('Add your favorite recipes to get started',
                                  style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          var recipe = snapshot.data!.docs[index].data() as Map<
                              String,
                              dynamic>;
                          return _buildRecipeCard(
                              recipe, snapshot.data!.docs[index].id);
                        },
                        childCount: snapshot.data!.docs.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Add to Cart',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CartPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View Cart',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart() async {
    var userId = _auth.currentUser?.uid;
    if (userId == null) return;

    var menuSnapshot = await _firestore.collection('users')
        .doc(userId)
        .collection('recipes')
        .get();
    var cartRef = _firestore.collection('users').doc(userId).collection('cart');

    for (var doc in menuSnapshot.docs) {
      var recipeData = doc.data();
      var cartItem = await cartRef.doc(doc.id).get();

      if (!cartItem.exists) {
        await cartRef.doc(doc.id).set(recipeData);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipes added to cart!')));
  }

  void _removeFromMenu(String recipeId) async {
    var userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).collection('recipes').doc(
        recipeId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe removed from My Menu')));
  }

  void _showRecipeDetails(Map<String, dynamic> recipe, String recipeId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, controller) => Container(
          padding: EdgeInsets.all(16),
          child: ListView(
            controller: controller,
            children: [
              if (recipe['imageUrl'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    recipe['imageUrl'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 16),
              Text(
                recipe['name'] ?? 'Unnamed Recipe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Cooking Time: ${recipe['cookingTime'] ?? 'N/A'} mins",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Text("Ingredients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...recipe['ingredients'].map((ingredient) => Text("- $ingredient", style: TextStyle(fontSize: 16))).toList(),
              SizedBox(height: 16),
              Text("Instructions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(recipe['instructions'] ?? 'No instructions provided', style: TextStyle(fontSize: 16)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _removeFromMenu(recipeId);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[600]),
                child: Text("Remove from My Menu"),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildRecipeCard(Map<String, dynamic> recipe, String recipeId) {
    return GestureDetector(
      onTap: () => _showRecipeDetails(recipe, recipeId),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
              child: recipe['imageUrl'] != null
                  ? Image.network(recipe['imageUrl'], height: 120, width: double.infinity, fit: BoxFit.cover)
                  : Container(
                height: 120,
                color: Colors.grey[200],
                child: Icon(Icons.restaurant, size: 40, color: Colors.grey[400]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe['name'] ?? 'Unnamed Recipe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  Text('${recipe['cookingTime'] ?? 'N/A'} mins',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  SizedBox(height: 1),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeFromMenu(recipeId),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
