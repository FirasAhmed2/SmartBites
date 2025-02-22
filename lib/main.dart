import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_page.dart'; // Import HomePage
import 'screens/home_screen.dart'; // Import HomeScreen
import 'screens/add_habit_screen.dart'; // Import AddHabitScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe Finder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/home', // Start with HomePage
      routes: {
        '/home': (context) => HomePage(), // HomePage with logout
        '/habits': (context) => HomeScreen(), // HomeScreen for habits
        '/addHabit': (context) => AddHabitScreen(), // AddHabitScreen
      },
    );
  }
}