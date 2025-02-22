import 'package:flutter/material.dart';
import '../firestore_service.dart'; // Import the FirestoreService

class AddHabitScreen extends StatelessWidget {
  final TextEditingController _habitController = TextEditingController();

  AddHabitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Habit"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _habitController,
              decoration: InputDecoration(
                labelText: "Habit Title",
                hintText: "e.g., Morning Workout",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final habitTitle = _habitController.text.trim();
                if (habitTitle.isNotEmpty) {
                  FirestoreService().addHabit(habitTitle);
                  Navigator.pop(context); // Go back to the previous screen
                }
              },
              child: Text("Add Habit"),
            ),
          ],
        ),
      ),
    );
  }
}