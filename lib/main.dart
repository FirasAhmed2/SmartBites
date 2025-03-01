import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'favorites.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables correctly
  await dotenv.load(fileName: "assets/api.env");

  await Firebase.initializeApp();
  runApp(MyApp());

}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/favorites', // Always start with WelcomePage
      routes: {
        '/welcome': (context) => WelcomePage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/favorites': (context) =>FavPage()
      },
    );
  }
}
