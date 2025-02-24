import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      backgroundColor: Colors.blue.shade50,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1: See Plans & Prices
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade700, // Fallback color
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),

              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Healthy, Delicious Meals 🍽️",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Choose a plan that fits your lifestyle. Fresh ingredients delivered every week.",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // SECTION 2: Recommended Recipes (modified)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "🍽️ Recommended Recipes",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            recipes.isEmpty
                ? Center(child: CircularProgressIndicator())
                : SizedBox(
              height: 220, // Fixed height for the horizontal scroll view
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 10),
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 200,
                    margin: EdgeInsets.only(right: 10),
                    child: RecipeCard(recipe: recipes[index]),
                  );
                },
              ),
            ),

            SizedBox(height: 20),

            // SECTION 3: Deliveries Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "🚚 Your Deliveries",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Stay updated on your upcoming orders and ingredients.",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),

                  // Subsection: Upcoming Deliveries
                  Text(
                    "📦 Upcoming Deliveries",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
                            Icon(Icons.delivery_dining, color: Colors.blue.shade700),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text("✅ 3 meals scheduled"),
                        SizedBox(height: 5),
                        Text("🥦 Ingredients: Tomatoes, Chicken, Spinach..."),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                  // Subsection: Track Delivery
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        print("Track Delivery clicked");
                      },
                      child: Text("Track Delivery"),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // SECTION 4: Help & Contact
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Need Help?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          print("Contact Us clicked");
                        },
                        child: Text("📞 Contact Us"),
                      ),
                      TextButton(
                        onPressed: () {
                          print("FAQs clicked");
                        },
                        child: Text("❓ FAQs"),
                      ),
                      TextButton(
                        onPressed: () {
                          print("Terms clicked");
                        },
                        child: Text("📜 Terms & Conditions"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeCard extends StatelessWidget {
  final dynamic recipe;
  const RecipeCard({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              recipe["image"] ?? "",
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe["title"],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                if (recipe["readyInMinutes"] != null)
                  Text(
                    "⏱️ ${recipe["readyInMinutes"]} mins",
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
