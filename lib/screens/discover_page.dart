import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';

class DiscoverPage extends StatefulWidget {
  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchRandomRecipes();
  }

  Future<void> fetchRandomRecipes() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/random?number=10&apiKey=${ApiConfig.spoonacularApiKey}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipes = List<Map<String, dynamic>>.from(data['recipes']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipes: $e')),
      );
    }
  }

  Future<void> addToMyMenu(Map<String, dynamic> recipe) async {
    try {
      // Extract ingredients from the recipe
      List<String> ingredients = [];
      if (recipe['extendedIngredients'] != null) {
        ingredients = List<String>.from(
          recipe['extendedIngredients'].map((ing) => ing['original']),
        );
      }

      // Add to Firestore
      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('recipes')
          .add({
        'name': recipe['title'],
        'cookingTime': recipe['readyInMinutes'] ?? 0,
        'ingredients': ingredients,
        'instructions': recipe['instructions'] ?? '',
        'rating': recipe['spoonacularScore']?.toDouble() ?? 0.0,
        'imageUrl': recipe['image'],
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Recipe added to your menu!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding recipe: $e')),
      );
    }
  }

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
                'Discover Recipes',
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
                icon: Icon(Icons.refresh, color: Colors.white),
                onPressed: fetchRandomRecipes,
                tooltip: "Get New Recipes",
              ),
            ],
          ),
          if (isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                ),
              ),
            )
          else
            SliverPadding(
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
                    final recipe = recipes[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        onTap: () => _showRecipeDetails(recipe),
                        borderRadius: BorderRadius.circular(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(15)),
                              child: Image.network(
                                recipe['image'] ?? '',
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 120,
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.restaurant,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    recipe['title'] ?? 'Unnamed Recipe',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${recipe['readyInMinutes'] ?? 'N/A'} mins',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: recipes.length,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      recipe['image'] ?? '',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      onPressed: () {
                        addToMyMenu(recipe);
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.green[600],
                      child: Icon(Icons.add),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                recipe['title'] ?? 'Unnamed Recipe',
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
                    '${recipe['readyInMinutes'] ?? 'N/A'} mins',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(width: 16),
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    '${(recipe['spoonacularScore'] ?? 0.0).toStringAsFixed(1)}',
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
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    ...(recipe['extendedIngredients'] as List? ?? []).map(
                      (ingredient) => Padding(
                        padding: EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.fiber_manual_record, size: 8),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(ingredient['original'] ?? ''),
                            ),
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
            ],
          ),
        ),
      ),
    );
  }
} 