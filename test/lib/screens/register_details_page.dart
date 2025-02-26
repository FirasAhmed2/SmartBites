import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  final String name;
  final int age;
  final double weight;
  final double height;

  UserDetails({
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      name: json['name'] as String,
      age: json['age'] as int,
      weight: json['weight'] as double,
      height: json['height'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
    };
  }
}

class RegisterDetailsPage extends StatefulWidget {
  final String email;
  final String password;

  RegisterDetailsPage({required this.email, required this.password});

  @override
  _RegisterDetailsPageState createState() => _RegisterDetailsPageState();
}

class _RegisterDetailsPageState extends State<RegisterDetailsPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  bool _isLoading = false;

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create the user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      // Get the user's UID
      String userId = userCredential.user!.uid;

      // Create UserDetails object
      UserDetails userDetails = UserDetails(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0,
        weight: double.tryParse(_weightController.text.trim()) ?? 0.0,
        height: double.tryParse(_heightController.text.trim()) ?? 0.0,
      );

      // Save user details to Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).set(userDetails.toJson());

      // Navigate to BasePage after successful registration
      Navigator.pushReplacementNamed(context, '/base');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code}, ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: ${e.message}")),
      );
    } catch (e) {
      print('Unknown error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unknown error occurred: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Additional Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Age"),
            ),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Weight (kg)"),
            ),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Height (cm)"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _registerUser,
              child: _isLoading ? CircularProgressIndicator() : Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}