import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.green[600],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'My Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green[400]!,
                      Colors.green[600]!,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: Colors.white),
                onPressed: () => _showAddRecipeDialog(context),
                tooltip: "Add Recipe",
              ),
            ],
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
                  child: Center(child: Text('Something went wrong')),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                    ),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant_menu,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No recipes yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your favorite recipes to get started',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
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
                      var recipe = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      return _buildRecipeCard(recipe, snapshot.data!.docs[index].id);
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRecipeDialog(context),
        backgroundColor: Colors.green[600],
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildRecipeCard(Map<String, dynamic> recipe, String recipeId) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: () => _showRecipeDetails(recipe),
            borderRadius: BorderRadius.circular(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: recipe['imageUrl'] != null
                      ? Image.network(
                          recipe['imageUrl'],
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: Icon(
                            Icons.restaurant,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe['name'] ?? 'Unnamed Recipe',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${recipe['cookingTime'] ?? 'N/A'} mins',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4),
                          Text(
                            recipe['rating']?.toString() ?? 'N/A',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => _confirmDeleteRecipe(recipeId, recipe['name'] ?? 'this recipe'),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetails(Map<String, dynamic> recipe) {
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timer, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    '${recipe['cookingTime'] ?? 'N/A'} mins',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    recipe['rating']?.toString() ?? 'N/A',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              ...(recipe['ingredients'] as List<dynamic>? ?? []).map(
                (ingredient) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.fiber_manual_record, size: 8),
                      SizedBox(width: 8),
                      Text(ingredient),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(recipe['instructions'] ?? 'No instructions provided'),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddRecipeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final timeController = TextEditingController();
    final ingredientsController = TextEditingController();
    final instructionsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Recipe'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Recipe Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: timeController,
                decoration: InputDecoration(
                  labelText: 'Cooking Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              TextField(
                controller: ingredientsController,
                decoration: InputDecoration(
                  labelText: 'Ingredients (comma separated)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 16),
              TextField(
                controller: instructionsController,
                decoration: InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                await _firestore
                    .collection('users')
                    .doc(_auth.currentUser?.uid)
                    .collection('recipes')
                    .add({
                  'name': nameController.text,
                  'cookingTime': int.tryParse(timeController.text) ?? 0,
                  'ingredients': ingredientsController.text
                      .split(',')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList(),
                  'instructions': instructionsController.text,
                  'rating': 0.0,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
            ),
            child: Text('Add Recipe'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteRecipe(String recipeId, String recipeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Recipe'),
        content: Text('Are you sure you want to remove "$recipeName" from your menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestore
                    .collection('users')
                    .doc(_auth.currentUser?.uid)
                    .collection('recipes')
                    .doc(recipeId)
                    .delete();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Recipe removed successfully'),
                    backgroundColor: Colors.green[600],
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error removing recipe: $e'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
} 