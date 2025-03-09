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
      body: _user == null || _userData.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.green[600],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _userData['name'] ?? 'No Name Provided',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.green[400]!,
                            Colors.green[600]!,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                backgroundImage: _user!.photoURL != null
                                    ? NetworkImage(_user!.photoURL!)
                                    : null,
                                child: _user!.photoURL == null
                                    ? Icon(Icons.person,
                                        size: 50, color: Colors.green[600])
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.logout, color: Colors.white),
                      onPressed: _signOut,
                      tooltip: "Log Out",
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 16),
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildDetailRow(
                                  Icons.cake_outlined,
                                  "Age",
                                  "${_userData['age'] ?? 'N/A'}",
                                  Colors.orange,
                                ),
                                Divider(height: 24),
                                _buildDetailRow(
                                  Icons.monitor_weight_outlined,
                                  "Weight",
                                  "${_userData['weight'] ?? 'N/A'} kg",
                                  Colors.blue,
                                ),
                                Divider(height: 24),
                                _buildDetailRow(
                                  Icons.height_outlined,
                                  "Height",
                                  "${_userData['height'] ?? 'N/A'} cm",
                                  Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final updatedUserData = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProfile(userData: _userData),
                                ),
                              );

                              if (updatedUserData != null) {
                                _saveUserData(updatedUserData);
                              }
                            },
                            icon: Icon(Icons.edit),
                            label: Text("Edit Profile"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green[600],
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // Helper method to build a row for details
  Widget _buildDetailRow(
      IconData icon, String label, String value, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
            SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}