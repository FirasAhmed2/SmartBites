import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:myapp/screens/login_page.dart';

void main() {
  group('LoginPage Widget Tests', () {
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockAuth = MockFirebaseAuth();
    });

    testWidgets('LoginPage renders UI correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(auth: mockAuth),
        ),
      );

      expect(find.text('Welcome Back!'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Email & Password
      expect(find.text('Log In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Shows error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(auth: mockAuth),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'invalidemail');
      await tester.enterText(find.byType(TextField).at(1), 'Password1');
      await tester.tap(find.text('Log In'));
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('Shows error for weak password when creating account', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LoginPage(auth: mockAuth),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'short');
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.textContaining('Password must be at least 6 characters'), findsOneWidget);
    });

    testWidgets('Successful login navigates to base page', (WidgetTester tester) async {
      final mockUser = MockUser(
        email: 'test@example.com',
        uid: '123',
      );
      mockAuth = MockFirebaseAuth(mockUser: mockUser);

      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/base': (context) => const Scaffold(body: Text('Base Page')),
          },
          home: LoginPage(auth: mockAuth),
        ),
      );

      await tester.enterText(find.byType(TextField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextField).at(1), 'Password1');
      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Base Page'), findsOneWidget);
    });
  });
}
