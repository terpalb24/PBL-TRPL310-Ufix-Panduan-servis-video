// lib/screens/history.dart
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: MediaQuery.of(context).size.width,
            height: 69,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF3A567A),
              border: Border.all(
                width: 1,
                color: const Color(0xFF3A567A),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontFamily: 'Kodchasan',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // History list
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHistoryItem(),
                    const SizedBox(height: 12),
                    _buildHistoryItem(),
                    const SizedBox(height: 12),
                    _buildHistoryItem(),
                    const SizedBox(height: 12),
                    _buildHistoryItem(),
                    const SizedBox(height: 12),
                    _buildHistoryItem(),
                    const SizedBox(height: 12),
                    _buildHistoryItem(),
                    const SizedBox(height: 12),
                    _buildHistoryItem(),
                    const SizedBox(height: 12),
                    _buildHistoryItem(),
                    const SizedBox(height: 12),
                    _buildHistoryItem(),
                    
                    // Load more button
                    const SizedBox(height: 28),
                    Container(
                      width: 100,
                      height: 30,
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
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom navigation
          Container(
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
                
                // Search button
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/search');
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: const Color(0xFFF7F7FA), size: 24),
                      const SizedBox(height: 4),
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
                
                // History button (you can add this to make it accessible)
                GestureDetector(
                  onTap: () {
                    // Already on history page
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, color: const Color(0xFFFF7F00), size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'History',
                        style: TextStyle(
                          color: const Color(0xFFFF7F00),
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
        ],
      ),
    );
  }
  
  // Helper method for history items
  Widget _buildHistoryItem() {
    return Container(
      width: double.infinity,
      height: 98,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.98, -0.00),
          end: Alignment(0.02, 1.00),
          colors: [const Color(0xFFEFF7FC), const Color(0xFFF7F7FA)],
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0x333A567A),
          ),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 140,
            height: 80,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: NetworkImage("https://placehold.co/140x80"),
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 11),
          
          // Video info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  'Video_Title',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Uploader',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  'Date/Month/Year',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}