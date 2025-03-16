import 'package:flutter/material.dart';

class RecipeDetailsPage extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String cookingTime;
  final List<dynamic> ingredients;

  RecipeDetailsPage({
    required this.imageUrl,
    required this.name,
    required this.cookingTime,
    required this.ingredients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, height: 250, width: double.infinity, fit: BoxFit.cover)
                  : Container(
                height: 250,
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 16),
            Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text("Cooking Time: $cookingTime mins", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            SizedBox(height: 16),
            Text("Ingredients", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            ...ingredients.map((ingredient) => Text("- $ingredient", style: TextStyle(fontSize: 16))).toList(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
