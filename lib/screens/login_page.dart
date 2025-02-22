import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  bool _isEmailValid(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isPasswordValid(String password) {
    return password.length >= 6 && password.contains(RegExp(r'[A-Z]'));
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (!_isEmailValid(_emailController.text.trim())) {
      setState(() {
        _errorMessage = "Please enter a valid email address";
        _isLoading = false;
      });
      return;
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to HomeScreen after successful login
      Navigator.pushReplacementNamed(context, '/habits');
    } catch (e) {
      setState(() {
        _errorMessage = "Invalid email or password";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    if (!_isEmailValid(_emailController.text.trim())) {
      setState(() {
        _errorMessage = "Please enter a valid email address";
        _isLoading = false;
      });
      return;
    }

    String password = _passwordController.text.trim();
    if (!_isPasswordValid(password)) {
      setState(() {
        _errorMessage = "Password must be at least 6 characters & include 1 uppercase letter";
        _isLoading = false;
      });
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: password,
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('firstLaunch', false);

      setState(() {
        _errorMessage = "Account Created. Please Login.";
      });

      // Navigate to HomeScreen after successful registration
      Navigator.pushReplacementNamed(context, '/habits');
    } catch (e) {
      setState(() {
        _errorMessage = "Registration Failed: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Account / Login")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              child: _isLoading ? CircularProgressIndicator() : Text("Login"),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading ? CircularProgressIndicator() : Text("Register"),
            ),
            SizedBox(height: 10),
            Text(_errorMessage, style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}