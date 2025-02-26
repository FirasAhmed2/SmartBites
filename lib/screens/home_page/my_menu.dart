import 'package:flutter/material.dart';

class MyMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Menu"),
      ),
      body: Center(
        child: Text('Welcome to My Menu!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
