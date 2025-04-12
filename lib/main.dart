import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:myapp/screens/home_page/base_page.dart';
import 'package:myapp/screens/login_page.dart'; // Import LoginPage
import 'package:myapp/screens/home_page/base_page.dart'; // Import base page
import 'package:myapp/screens/welcome_page.dart'; // Import WelcomePage
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/screens/CheckoutPage.dart'; // Import LoginPage
import 'package:myapp/screens/home_page/animation_page.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/api.env");
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Habit Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/animation', // Start with WelcomePage
      routes: {
        '/animation': (context) => AnimationPage(), // WelcomePage
        '/welcome': (context) => WelcomePage(), // WelcomePage
        '/': (context) => Wrapper(), // Wrapper to handle authentication state
        '/login': (context) => LoginPage(), // LoginPage
        '/base': (context) => BasePage(), // BasePage manages navigation once logged in
      },
    );
  }
}

// Wrapper widget embedded directly in main.dart
class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return LoginPage(); // Show login page if user is not logged in
          } else {
            return BasePage(); // Navigate to BasePage if user is logged in
          }
        }
        // Show loading spinner while checking authentication state
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
