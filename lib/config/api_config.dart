import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get spoonacularApiKey => dotenv.env['SPOONACULAR_API_KEY'] ?? '';
  static const String baseUrl = 'https://api.spoonacular.com/recipes';
} 