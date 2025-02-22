import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // Add a new habit to Firestore
  Future<void> addHabit(String title) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .add({
            "title": title,
            "streak": 0,
            "completedToday": false,
            "timestamp": DateTime.now(),
          });
    }
  }

  // Fetch habits for the current user
  Stream<QuerySnapshot> getHabits() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .snapshots();
    } else {
      throw Exception("User not logged in");
    }
  }
}