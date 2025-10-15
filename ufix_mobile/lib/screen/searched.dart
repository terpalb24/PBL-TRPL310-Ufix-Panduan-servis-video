// lib/screens/searched_videos.dart
import 'package:flutter/material.dart';

class SearchedVideos extends StatelessWidget {
  const SearchedVideos({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: const Color(0xFFF7F7FA),
          ),
          
          // Filter section
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 135,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FA),
                border: Border.all(width: 1, color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Active filters
                  Container(
                    width: 350,
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEFF7FC),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0x663A567A),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Active filter chips
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildActiveFilterChip('Tag'),
                            _buildActiveFilterChip('Tag Long'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 23),
                  
                  // Filter buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFilterButton('Urutkan dari'),
                      _buildFilterButton('Saring Berdasarkan'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Search results
          Positioned(
            top: 135,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 210,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildVideoResultItem(),
                    const SizedBox(height: 12),
                    _buildVideoResultItem(),
                    const SizedBox(height: 12),
                    _buildVideoResultItem(),
                    const SizedBox(height: 12),
                    _buildVideoResultItem(),
                    const SizedBox(height: 12),
                    _buildVideoResultItem(),
                    const SizedBox(height: 12),
                    _buildVideoResultItem(),
                    const SizedBox(height: 12),
                    _buildVideoResultItem(),
                    const SizedBox(height: 12),
                    _buildVideoResultItem(),
                    const SizedBox(height: 12),
                    _buildVideoResultItem(),
                    
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
  
  // Helper method for active filter chips
  Widget _buildActiveFilterChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          // Close button
          GestureDetector(
            onTap: () {
              // Remove filter
            },
            child: Icon(
              Icons.close,
              size: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method for filter buttons
  Widget _buildFilterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
      child: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  // Helper method for video result items
  Widget _buildVideoResultItem() {
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