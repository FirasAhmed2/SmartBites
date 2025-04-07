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
  List<Map<String, dynamic>> filteredRecipes = [];
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  String _sortOption = 'none'; // 'none', 'shortest', 'longest'
  Set<String> favoriteRecipes = {};

  @override
  void initState() {
    super.initState();
    fetchRandomRecipes();
    _loadFavorites();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    if (_auth.currentUser != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('favorites')
          .get();
      
      setState(() {
        favoriteRecipes = snapshot.docs.map((doc) => doc.id).toSet();
      });
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> recipe) async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to save favorites')),
      );
      return;
    }

    final recipeId = recipe['id'].toString();
    final isFavorite = favoriteRecipes.contains(recipeId);

    try {
      if (isFavorite) {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('favorites')
            .doc(recipeId)
            .delete();
        setState(() {
          favoriteRecipes.remove(recipeId);
        });
      } else {
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .collection('favorites')
            .doc(recipeId)
            .set({
          'title': recipe['title'],
          'image': recipe['image'],
          'readyInMinutes': recipe['readyInMinutes'],
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() {
          favoriteRecipes.add(recipeId);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating favorite: $e')),
      );
    }
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
          filteredRecipes = List.from(recipes);
          _applySorting();
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

  void _searchRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRecipes = List.from(recipes);
      } else {
        filteredRecipes = recipes.where((recipe) {
          // Search in title
          if (recipe['title'].toString().toLowerCase().contains(query.toLowerCase())) {
            return true;
          }
          // Search in ingredients
          if (recipe['extendedIngredients'] != null) {
            return recipe['extendedIngredients'].any((ingredient) =>
                ingredient['original'].toString().toLowerCase().contains(query.toLowerCase()));
          }
          return false;
        }).toList();
      }
      _applySorting();
    });
  }

  void _applySorting() {
    switch (_sortOption) {
      case 'shortest':
        filteredRecipes.sort((a, b) => (a['readyInMinutes'] ?? 0).compareTo(b['readyInMinutes'] ?? 0));
        break;
      case 'longest':
        filteredRecipes.sort((a, b) => (b['readyInMinutes'] ?? 0).compareTo(a['readyInMinutes'] ?? 0));
        break;
      default:
        // No sorting
        break;
    }
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort by Cooking Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Shortest to Longest'),
                onTap: () {
                  setState(() {
                    _sortOption = 'shortest';
                    _applySorting();
                  });
                  Navigator.pop(context);
                },
                trailing: _sortOption == 'shortest' ? Icon(Icons.check, color: Colors.green) : null,
              ),
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Longest to Shortest'),
                onTap: () {
                  setState(() {
                    _sortOption = 'longest';
                    _applySorting();
                  });
                  Navigator.pop(context);
                },
                trailing: _sortOption == 'longest' ? Icon(Icons.check, color: Colors.green) : null,
              ),
              ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('No Sorting'),
                onTap: () {
                  setState(() {
                    _sortOption = 'none';
                    if (_searchController.text.isNotEmpty) {
                      _searchRecipes(_searchController.text);
                    } else {
                      filteredRecipes = List.from(recipes);
                    }
                  });
                  Navigator.pop(context);
                },
                trailing: _sortOption == 'none' ? Icon(Icons.check, color: Colors.green) : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addToMyMenu(Map<String, dynamic> recipe) async {
    try {
      List<String> ingredients = [];
      if (recipe['extendedIngredients'] != null) {
        ingredients = List<String>.from(
          recipe['extendedIngredients'].map((ing) => ing['original']),
        );
      }

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
      body: RefreshIndicator(
        onRefresh: fetchRandomRecipes,
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildDiscoverAppBar(),
            if (isLoading)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading delicious recipes...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
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
                      final recipe = filteredRecipes[index];
                      return _buildRecipeCard(recipe);
                    },
                    childCount: filteredRecipes.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: Colors.green[600],
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Text(
                "Discover Recipes 🍽️",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              "Find new recipes to try and add them to you menu!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _searchRecipes,
                      decoration: InputDecoration(
                        hintText: 'Search recipes or ingredients...',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.search, color: Colors.green[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.sort,
                      color: _sortOption != 'none' ? Colors.white : Colors.white70,
                    ),
                    onPressed: _showSortOptions,
                    tooltip: "Sort recipes",
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.white),
                    onPressed: fetchRandomRecipes,
                    tooltip: "Get New Recipes",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single recipe card
  Widget _buildRecipeCard(Map<String, dynamic> recipe) {
    final recipeId = recipe['id'].toString();
    final isFavorite = favoriteRecipes.contains(recipeId);

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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.network(
                    recipe['image'] ?? '',
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(recipe),
                  ),
                ),
              ],
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
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${recipe['readyInMinutes'] ?? 'N/A'} mins',
                        style: TextStyle(
                          color: Colors.grey[600],
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
    );
  }

  /// Shows a detailed recipe modal before adding to My Menu
  void _showRecipeDetails(Map<String, dynamic> recipe) {
    List<String> ingredients = [];
    if (recipe['extendedIngredients'] != null) {
      ingredients = List<String>.from(
        recipe['extendedIngredients'].map((ing) => ing['original']),
      );
    }

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
              if (recipe['image'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    recipe['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 16),
              Text(
                recipe['title'] ?? 'Unnamed Recipe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                "Cooking Time: ${recipe['readyInMinutes'] ?? 'N/A'} mins",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 16),
              Text("Ingredients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...ingredients.map((ingredient) => Text("- $ingredient", style: TextStyle(fontSize: 16))).toList(),
              SizedBox(height: 16),
              Text("Instructions", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(recipe['instructions'] ?? 'No instructions provided', style: TextStyle(fontSize: 16)),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  addToMyMenu(recipe);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
                child: Text("Add to My Menu"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
