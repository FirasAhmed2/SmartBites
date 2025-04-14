import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/screens/menu_page.dart';

class FakeAuth extends Fake implements FirebaseAuth {
  final String uid;

  FakeAuth(this.uid);

  @override
  User? get currentUser => FakeUser(uid);
}

class FakeUser extends Fake implements User {
  final String _uid;

  FakeUser(this._uid);

  @override
  String get uid => _uid;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFirebaseFirestore firestore;
  late FakeAuth fakeAuth;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    fakeAuth = FakeAuth("test-user");

    // Add one recipe
    await firestore.collection('users')
        .doc("test-user")
        .collection('recipes')
        .doc('recipe1')
        .set({
      'name': 'Spaghetti',
      'imageUrl': null,
      'cookingTime': 15,
      'ingredients': ['pasta', 'sauce'],
      'instructions': 'Boil and mix'
    });
  });

  testWidgets('should render more recipe cards when a recipe is added', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MenuPage(
        auth: fakeAuth,
        firestore: firestore,
      ),
    ));

    await tester.pumpAndSettle();

    // Initially 1 recipe card
    expect(find.byKey(Key('recipe_card_recipe1')), findsOneWidget);

    // Add a second recipe
    await firestore.collection('users')
        .doc("test-user")
        .collection('recipes')
        .doc('recipe2')
        .set({
      'name': 'Tacos',
      'imageUrl': null,
      'cookingTime': 10,
      'ingredients': ['tortilla', 'meat'],
      'instructions': 'Assemble and serve'
    });

    // Wait for the UI to update
    await tester.pumpAndSettle();

    // Now 2 recipe cards should be rendered
    expect(find.byKey(Key('recipe_card_recipe1')), findsOneWidget);
    expect(find.byKey(Key('recipe_card_recipe2')), findsOneWidget);
  });
}
