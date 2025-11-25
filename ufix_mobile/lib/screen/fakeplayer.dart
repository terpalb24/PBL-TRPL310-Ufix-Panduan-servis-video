// lib/screens/fake_player.dart
import 'package:flutter/material.dart';

class FakePlayer extends StatelessWidget {
  const FakePlayer({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video area (black background)
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Center(
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 80,
              ),
            ),
          ),
          
          // Video info overlay
          Positioned(
            top: 40,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video_Title',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Kodchasan',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '30-12-2000',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Side menu (Details, Comments, Bookmark)
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 100,
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  _buildSideButton('Detail'),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/comments'),
                    child: _buildSideButton('Komentar'),
                  ),
                  SizedBox(height: 20),
                  _buildSideButton('Bookmark'),
                ],
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
                        SizedBox(height: 4),
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
                  
                  // Search button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/search');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, color: const Color(0xFFF7F7FA), size: 24),
                        SizedBox(height: 4),
                        Text(
                          'Search',
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
                  
                  // Bookmark button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/bookmark');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark, color: const Color(0xFFF7F7FA), size: 24),
                        SizedBox(height: 4),
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
  
  Widget _buildSideButton(String text) {
    return GestureDetector(
      onTap: () {
        // Handle button tap
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Text(
          text,
          style: TextStyle(
            color: const Color(0xFFF7F7FA),
            fontSize: 14,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}