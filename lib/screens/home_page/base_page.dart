import 'package:flutter/material.dart';
import 'package:myapp/screens/home_page/home_page.dart';
import 'package:myapp/screens/menu_page.dart';
import 'package:myapp/screens/orders_page.dart';
import 'package:myapp/screens/profile.dart';
import 'package:myapp/screens/discover_page.dart';

class BasePage extends StatefulWidget {
  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    HomePage(),
    MenuPage(),
    DiscoverPage(),
    OrdersPage(),
    Profile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.green[700], // Selected color
          unselectedItemColor: Colors.grey[600], // Unselected color
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu, size: 24),
              label: 'My Menu',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6), // Adds padding for better emphasis
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[700], // Always green
                ),
                child: Icon(Icons.explore, size: 32, color: Colors.white), // Bigger and white inside
              ),
              label: '', // 🔥 Removes the "Discover" label
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long, size: 24),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
