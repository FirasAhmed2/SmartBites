import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firestore_service.dart'; // Import the FirestoreService

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Habits"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirestoreService().getHabits(), // Fetch habits
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final habits = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(habit['title']),
                subtitle: Text('Streak: ${habit['streak']}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addHabit'); // Navigate to AddHabitScreen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}