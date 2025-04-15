import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:myapp/main.dart' as app;

void main() {
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

      group('Login Flow Integration Test', () {
            testWidgets('should log in successfully and navigate to BasePage',
                    (WidgetTester tester) async {
                      // Start the app
                      app.main();
                      await tester.pumpAndSettle();
                      // **** ADD THIS LINE ****
                      await tester.pump(const Duration(milliseconds: 10000)); // Add a small pump

                      // --- Navigate from WelcomePage to LoginPage ---
                      final Finder welcomeLoginButton = find.byKey(Key('welcomeLoginButton'));

                      // This expectation should now pass
                      expect(welcomeLoginButton, findsOneWidget);
                      await tester.tap(welcomeLoginButton);
                      await tester.pumpAndSettle();

                      // --- Now we're on the LoginPage ---
                      expect(find.text('Welcome Back!'), findsOneWidget); // Text from login_page.dart

                      // Find the input fields and login button
                      final Finder emailField = find.widgetWithText(TextField, 'Email');
                      final Finder passwordField = find.widgetWithText(TextField, 'Password');
                      // **** POTENTIAL IMPROVEMENT: Use a specific Key for the login button ****
                      // It's generally better to use Keys than text for finding widgets in tests.
                      // Consider adding a Key('loginButton') to your ElevatedButton in login_page.dart
                      // and changing the line below to:
                      // final Finder loginButton = find.byKey(Key('loginButton'));
                      final Finder loginButton = find.widgetWithText(ElevatedButton, 'Log In');


                      expect(emailField, findsOneWidget);
                      expect(passwordField, findsOneWidget);
                      expect(loginButton, findsOneWidget);

                      // Enter test credentials
                      await tester.enterText(emailField, 'omarmail@mail.com');
                      await tester.pumpAndSettle();
                      await tester.enterText(passwordField, 'PasswordPassword');
                      await tester.pumpAndSettle();

                      // Tap login
                      await tester.tap(loginButton);
                      // Consider reducing this settle duration if possible, but Firebase auth can take time.
                      await tester.pumpAndSettle(const Duration(seconds: 20));

                      // --- Verify successful login and navigation ---
                      // Ensure BasePage has a widget with Key('basePageScaffold')
                      expect(find.byKey(Key('basePageScaffold')), findsOneWidget);
                });
      });
}