import 'package:flutter/material.dart';
import 'package:myapp/screens/Welcome_page.dart';

class AnimationPage extends StatefulWidget {
  @override
  _AnimationPageState createState() => _AnimationPageState();
}

class _AnimationPageState extends State<AnimationPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _positionAnimation;
  double _titleOpacity = 0.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 6 * 3.14).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _positionAnimation = Tween<double>(begin: -200, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Show title after fruit finishes rolling
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _titleOpacity = 1.0;
      });
    });

    // Navigate to WelcomePage after animation
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => WelcomePage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Transform.translate(
          offset: Offset(0, -60), // 👈 move content 60 pixels up
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_positionAnimation.value, 0),
                    child: Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Image.asset(
                        'assets/images/greenlemon.png',
                        height: 120,
                      ),
                    ),
                  );
                },
              ),
              AnimatedOpacity(
                opacity: _titleOpacity,
                duration: Duration(seconds: 2),
                child: Text(
                  'SmartBites',
                  style: TextStyle(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic, // Italic text
                    color: Colors.green[600],
                  ),
                ),
              ),const SizedBox(height: 250),
            ],
          ),
        ),
      ),
    );
  }
}
