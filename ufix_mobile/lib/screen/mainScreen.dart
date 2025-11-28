import 'package:flutter/material.dart';
import 'homepage.dart';
import 'search.dart';
import 'bookmark.dart';

class FrontScreen extends StatefulWidget {
  const FrontScreen({super.key});

  @override
  State<FrontScreen> createState() => _FrontScreenState();
}

class _FrontScreenState extends State<FrontScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    Homepage(),
    Search(),
    Bookmark(),
  ];

  void _onItemTapped (int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFF7F7FA),
        selectedItemColor: Color(0XFFFF7F00),
        unselectedItemColor: Color(0xFF3A567A),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            activeIcon: Icon(Icons.bookmark),
            label: 'bookmark',
          ),
        ],
      ),
    );
  }
}