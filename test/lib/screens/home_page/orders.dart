import 'package:flutter/material.dart';

class Orders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
      ),
      body: Center(
        child: Text('My Orders!', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}