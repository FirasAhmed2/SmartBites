import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> recipes = [];
  final String apiKey = dotenv.env['API_KEY']!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }
  //unit test
  void testfetchRecipes(List<dynamic> recipes){
    print("test for the fetch recipes function to ensure that recipes were obtained");
    for (var l in recipes){
      print("list item: $l");
    }
  }

  Future<void> fetchRecipes() async {
    final url = Uri.parse("https://api.spoonacular.com/recipes/random?apiKey=$apiKey&number=6");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          recipes = data["recipes"] ?? [];
          testfetchRecipes(recipes);
        });
      } else {
        print("Failed to fetch recipes: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching recipes: $e");
    }
  }

//unit test
  Future<void> test_addRecipToMenu(String recipeName) async {
    final user = _auth.currentUser;

    if (user == null) {
      print(" User is not logged in.");
      return;
    }

    try {
      print(" Checking if recipe '$recipeName' exists in Firestore...");

      final rec = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('recipes')
          .where('name', isEqualTo: recipeName)
          .get();

      if (rec.docs.isNotEmpty) {
        print(" Recipe found in Firestore:");
        for (var doc in rec.docs) {
          print(doc.data());
        }
      } else {
        print(" Recipe not found.");
      }
    } catch (e, stack) {
      print(" Error while checking Firestore: $e");
      print(stack);
    }
  }


  /// **Function to Add Recipe to "My Menu"**
  Future<void> _addRecipeToMenu(Map<String, dynamic> recipe) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).collection('recipes').add({
          'name': recipe['title'],
          'cookingTime': recipe['readyInMinutes'] ?? 0,
          'ingredients': (recipe['extendedIngredients'] as List?)
              ?.map((e) => e['original'])
              .toList() ??
              [],
          'instructions': recipe['instructions'] ?? 'No instructions provided',
          'imageUrl': recipe['image'] ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        test_addRecipToMenu(recipe['title']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Recipe added to My Menu!"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error adding recipe: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRecipeDetails(BuildContext context, Map<String, dynamic> recipe) {
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
                  _addRecipeToMenu(recipe);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHomeAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "🍽️ Recommended Recipes",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 2),
                recipes.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: EdgeInsets.only(right: 10),
                        child: RecipeCard(
                          recipe: recipes[index],
                          onTap: () => _showRecipeDetails(context, recipes[index]), // Open details
                        ),
                      );
                    },
                  ),

                ),
                SizedBox(height: 20),
                _buildDeliverySection(),
                SizedBox(height: 20),
                _buildHelpSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 140.0,
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
                "Healthy, Delicious Meals 🍽️",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              "Choose a plan that fits your lifestyle.",
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("🚚 Your Deliveries", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("Stay updated on your upcoming orders and ingredients.", style: TextStyle(fontSize: 16)),
          SizedBox(height: 20),
          Text("📦 Upcoming Deliveries", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "🗓️ Delivery Date: March 2, 2025",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.delivery_dining, color: Colors.green.shade700),
                  ],
                ),
                SizedBox(height: 10),
                Text("✅ 3 meals scheduled"),
                SizedBox(height: 5),
                Text("🥦 Ingredients: Tomatoes, Chicken, Spinach..."),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Need Help?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(onPressed: () {}, child: Text("📞 Contact Us")),
              TextButton(onPressed: () {}, child: Text("❓ FAQs")),
              TextButton(onPressed: () {}, child: Text("📜 Terms & Conditions")),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

/// **Recipe Card Widget with Tap-to-Add Feature**
class RecipeCard extends StatelessWidget {
  final dynamic recipe;
  final VoidCallback onTap;

  const RecipeCard({Key? key, required this.recipe, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Now opens `_showRecipeDetails`
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Image.network(
              recipe["image"] ?? "",
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 110,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 50, color: Colors.grey[600]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                recipe["title"],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
