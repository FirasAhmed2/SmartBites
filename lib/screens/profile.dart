import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/home_page/EditProfile.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Map to hold user data fetched from Firestore
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchUserData(); // Fetch user data from Firestore
  }

  // Load the current user's data
  void _loadUser() {
    setState(() {
      _user = _auth.currentUser;
    });
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    if (_user != null) {
      try {
        // Fetch user document from Firestore
        DocumentSnapshot snapshot = await _firestore.collection('users').doc(_user!.uid).get();

        if (snapshot.exists) {
          setState(() {
            _userData = snapshot.data() as Map<String, dynamic>;
          });
        } else {
          // If no data exists, initialize with default values
          _saveUserData({
            'name': _user!.displayName ?? 'No Name',
            'age': 0,
            'weight': 0.0,
            'height': 0.0,
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(_user!.uid).set(data);
      setState(() {
        _userData = data; // Update local state
      });
    } catch (e) {
      print("Error saving user data: $e");
    }
  }

  // Sign out the user
  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/login'); // Navigate back to login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: "Log Out",
          ),
        ],
      ),
      body: _user == null || _userData.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator if user data isn't loaded yet
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(_user!.photoURL ?? ''),
              child: _user!.photoURL == null
                  ? Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            SizedBox(height: 20),

            // User Name
            Text(
              _userData['name'] ?? 'No Name Provided',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // User Details in a Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.cake, "Age", "${_userData['age'] ?? 'N/A'}"),
                    Divider(),
                    _buildDetailRow(Icons.monitor_weight, "Weight", "${_userData['weight'] ?? 'N/A'} kg"),
                    Divider(),
                    _buildDetailRow(Icons.height, "Height", "${_userData['height'] ?? 'N/A'} cm"),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Edit Profile Button
            ElevatedButton(
              onPressed: () async {
                final updatedUserData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfile(userData: _userData),
                  ),
                );

                if (updatedUserData != null) {
                  _saveUserData(updatedUserData); // Save updated data to Firestore
                }
              },
              child: Text("Edit Profile"),
            ),
            SizedBox(height: 20),

            // Log Out Button
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text("Log Out"),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a row for details
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[700]),
            SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}