import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'screens/home_screen.dart'; // Import HomeScreen
import 'screens/add_habit_screen.dart'; // Import AddHabitScreen
import 'screens/login_page.dart'; // Import LoginPage
import 'screens/Welcome_page.dart'; // Import WelcomePage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      initialRoute: '/welcome', // Start with WelcomePage
      routes: {
        '/welcome': (context) => WelcomePage(), // WelcomePage
        '/': (context) => Wrapper(), // Wrapper to handle authentication state
        '/login': (context) => LoginPage(), // LoginPage
        '/habits': (context) => HomeScreen(), // HomeScreen for habits
        '/addHabit': (context) => AddHabitScreen(), // AddHabitScreen
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
            return HomeScreen(); // Show home page if user is logged in
          }
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}