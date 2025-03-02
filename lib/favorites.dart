import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FavPage extends StatefulWidget {
  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  List<dynamic> recipes = [];
  List<dynamic> favoriteRecipes = [];
  final String apiKey = dotenv.env['API_KEY'] ?? "";

  @override
  void initState() {
    super.initState();
    load_favorites();
    fetch_recipes();
  }

  Future<void> fetch_recipes() async {
    final url = Uri.parse(
        "https://api.spoonacular.com/recipes/random?apiKey=$apiKey&number=10");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> data = json.decode(response.body);
        if (data.containsKey("recipes")) {
          setState(() {
            recipes = data["recipes"];
          });
        } else {
          print("Error: 'recipes' key not found in API response.");
        }
      } catch (e) {
        print("JSON Parsing Error: $e");
      }
    } else {
      print("Failed to fetch recipes: ${response.statusCode}");
    }
  }

  void add_to_favorites(dynamic recipe) {
    if (!favoriteRecipes.contains(recipe)) {
      setState(() {
        favoriteRecipes.add(recipe);
      });
      write_to_file();
      print("Added to favorites: ${recipe["title"]}");
    }
  }

  void remove_from_favorites(dynamic recipe) {
    setState(() {
      favoriteRecipes.remove(recipe);
    });
    write_to_file();
    print("Removed from favorites: ${recipe["title"]}");
  }

  Future<void> write_to_file() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/favorites.json');

      final jsonString = jsonEncode(favoriteRecipes);
      await file.writeAsString(jsonString);

      print("Favorites saved to: ${file.path}");
    } catch (e) {
      print("Error saving favorites: $e");
    }
  }


  Future<void> load_favorites() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/favorites.json');

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final List<dynamic> savedFavorites = jsonDecode(jsonString);

        setState(() {
          favoriteRecipes = savedFavorites;
        });

        print("Favorites loaded from file.");
      } else {
        print("Favorites file does not exist.");
      }
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favorites Page')),
      body: Column(
        children: [
          Expanded(
            child: favoriteRecipes.isEmpty
                ? Center(child: Text("No favorites yet!"))
                : ListView.builder(
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                return RecipeCard(
                  recipe: favoriteRecipes[index],
                  onRemove: () => remove_from_favorites(favoriteRecipes[index]),
                  save: () => write_to_file(),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ExpansionTile(
              title: Text("Available Recipes", style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Container(
                  height: 200,
                  child: ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(recipes[index]["title"]),
                        onTap: () => add_to_favorites(recipes[index]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final dynamic recipe;
  final VoidCallback onRemove;
  final VoidCallback save;

  const RecipeCard({Key? key, required this.recipe, required this.onRemove, required this.save}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: recipe["image"] != null
                ? Image.network(
              recipe["image"],
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            )
                : Icon(Icons.image, size: 120),
          ),
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe["title"] ?? "No Title",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                if (recipe["readyInMinutes"] != null)
                  Text(
                    " ${recipe["readyInMinutes"]} mins",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                SizedBox(height: 5),

                //
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onRemove,
                  ),
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: save,
                    child: Text("Save"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
