import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FavPage extends StatefulWidget {
  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  List<dynamic> recipes = [];
  final String apiKey = dotenv.env['API_KEY']!;

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    final url = Uri.parse("https://api.spoonacular.com/recipes/random?apiKey=$apiKey&number=6");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        recipes = data["recipes"] ?? [];
      });
    } else {
      print("Failed to fetch recipes: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade500,
      body: SingleChildScrollView(
        child: Column(
        children: [
          ElevatedButton(onPressed: onPressed, child: child)
      ],
    ),
    ),
    );
  }
  }
