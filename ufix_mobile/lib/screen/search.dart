// lib/screens/search.dart
import 'package:flutter/material.dart';

class Search extends StatelessWidget {
  const Search({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
          ),
          
          // Search bar
          Positioned(
            left: 25,
            top: 10,
            child: Container(
              width: MediaQuery.of(context).size.width - 50,
              height: 50,
              decoration: ShapeDecoration(
                color: const Color(0xFFEAEAEA),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFFD9D9D9),
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search videos...',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Main content
          Positioned(
            left: 0,
            top: 70,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 145,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recommended section
                    _buildSection('Disarankan', _buildRecommendedTags()),
                    
                    // All Tags section
                    _buildSection('Semua Tag', _buildAllTags()),
                    
                    // Load more button
                    Center(
                      child: Container(
                        width: 100,
                        height: 30,
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        decoration: ShapeDecoration(
                          gradient: LinearGradient(
                            begin: Alignment(0.50, 1.00),
                            end: Alignment(0.50, 0.00),
                            colors: [const Color(0xFFADE7F7), const Color(0xFFF7F7FA)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Lebih Banyak',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom navigation
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 75,
              color: const Color(0xFF3A567A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Home button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/home');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.home, color: const Color(0xFFF7F7FA), size: 24),
                        const SizedBox(height: 4),
                        Text(
                          'Home',
                          style: TextStyle(
                            color: const Color(0xFFF7F7FA),
                            fontSize: 11,
                            fontFamily: 'Kodchasan',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search button (active)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: const Color(0xFFFF7F00), size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'Search',
                        style: TextStyle(
                          color: const Color(0xFFFF7F00),
                          fontSize: 11,
                          fontFamily: 'Kodchasan',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  // Bookmark button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/bookmark');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark, color: const Color(0xFFF7F7FA), size: 24),
                        const SizedBox(height: 4),
                        Text(
                          'Bookmark',
                          style: TextStyle(
                            color: const Color(0xFFF7F7FA),
                            fontSize: 11,
                            fontFamily: 'Kodchasan',
                            fontWeight: FontWeight.w600,
                        ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method to build sections
  Widget _buildSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: const Color(0xFF3A567A),
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontFamily: 'Kodchasan',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
  
  // Recommended tags
  Widget _buildRecommendedTags() {
    final recommendedTags = [
      'Electronics', 'Repair', 'Tutorial', 'DIY', 'Circuit',
      'Soldering', 'Arduino', 'Raspberry Pi', 'Programming'
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: recommendedTags.map((tag) => _buildTag(tag)).toList(),
    );
  }
  
  // All tags (organized in categories)
  Widget _buildAllTags() {
    final tagCategories = {
      'Basic Electronics': ['Resistor', 'Capacitor', 'Transistor', 'Diode', 'LED'],
      'Tools': ['Multimeter', 'Oscilloscope', 'Soldering Iron', 'Wire Cutter'],
      'Programming': ['C++', 'Python', 'JavaScript', 'Arduino IDE'],
      'Projects': ['Robot', 'Drone', 'Smart Home', 'IoT', '3D Printing'],
      'Advanced': ['Microcontroller', 'PCB Design', 'Signal Processing']
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tagCategories.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.key,
              style: TextStyle(
                color: const Color(0xFF3A567A),
                fontSize: 14,
                fontFamily: 'Kodchasan',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entry.value.map((tag) => _buildTag(tag)).toList(),
            ),
            const SizedBox(height: 16),
          ],
        );
      }).toList(),
    );
  }
  
  // Individual tag widget
  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F7FA),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0xFF3A567A),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}