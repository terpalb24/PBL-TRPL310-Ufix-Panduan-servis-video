// lib/screens/bookmark.dart
import 'package:flutter/material.dart';

class Bookmark extends StatelessWidget {
  const Bookmark({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: const Color(0xFFF7F7FA)),
          ),
          
          // Header title
          Positioned(
            left: 13,
            top: 20,
            child: Text(
              'Bookmark',
              style: TextStyle(
                color: const Color(0xFF3A567A),
                fontSize: 40,
                fontFamily: 'Kodchasan',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          
          // Filter section
          Positioned(
            left: 0,
            top: 75,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 197,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 20),
              decoration: ShapeDecoration(
                color: const Color(0xFFF7F7FA),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFF3A567A),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    width: 239,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF0F7FC),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0x193A567A),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari Video bookmark...',
                              hintStyle: TextStyle(
                                color: Colors.black.withValues(alpha: 0.40),
                                fontSize: 14,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Filter buttons row 1
                  Row(
                    children: [
                      _buildFilterButton('Tampilkan Uploader'),
                      const SizedBox(width: 10),
                      _buildFilterButton('Tampilkan Dikomentari'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Filter buttons row 2
                  Row(
                    children: [
                      _buildFilterButton('Tampilkan Jumlah'),
                      const SizedBox(width: 10),
                      _buildFilterButton('Saring Berdasarkan'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  
                  // Sort button
                  _buildFilterButton('Urutkan dari'),
                ],
              ),
            ),
          ),
          
          // Bookmarked videos list
          Positioned(
            left: 0,
            top: 295,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 395,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildBookmarkedVideoItem(context),
                    const SizedBox(height: 10),
                    _buildBookmarkedVideoItem(context),
                    const SizedBox(height: 10),
                    _buildBookmarkedVideoItem(context),
                    const SizedBox(height: 10),
                    _buildBookmarkedVideoItem(context),
                    const SizedBox(height: 10),
                    _buildBookmarkedVideoItem(context),
                    const SizedBox(height: 10),
                    _buildBookmarkedVideoItem(context),
                    
                    // Load more button
                    const SizedBox(height: 20),
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
        ],
      ),
    );
  }
  
  // Helper method for filter buttons
  Widget _buildFilterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: ShapeDecoration(
        color: const Color(0xFFF0F7FC),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: const Color(0x663A567A),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 20,
            height: 20,
            decoration: ShapeDecoration(
              color: const Color(0x4C3A567A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method for bookmarked video items
  Widget _buildBookmarkedVideoItem(BuildContext context) {
    return GestureDetector(
      onTap: () {Navigator.pushNamed(context, '/player');},
      child: Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.98, -0.00),
          end: Alignment(0.02, 1.00),
          colors: [const Color(0xFFEFF7FC), const Color(0xFFF7F7FA)],
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0x333A567A)),
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
                image: AssetImage('Asset/Thumbnail-Fake.png'),
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
                    fontSize: 18,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Uploader',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  'Date/Month/Year',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}