// lib/screens/homepage.dart
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
 const Homepage({super.key});
 
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
          
          // Main content
          Positioned(
            left: 0,
            top: 90,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome banner
                  Container(
                    width: double.infinity,
                    height: 350,
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF3A567A)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, (display_name)!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontFamily: 'Kodchasan',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 78),
                        Container(
                          width: 286,
                          height: 164,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://placehold.co/286x164"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 78),
                        Text(
                          'Resume watching?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Kodchasan',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tab buttons
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      children: [
                        // Suggested tab
                        Expanded(
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F7FA),
                              border: Border.all(
                                width: 1,
                                color: const Color(0xFF3A567A),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Suggested',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontFamily: 'Jost',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Newest tab
                        Expanded(
                          child: Opacity(
                            opacity: 0.50,
                            child: Container(
                              height: 38,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7FA),
                                border: Border.all(
                                  width: 1,
                                  color: const Color(0xFF3A567A),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Newest',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontFamily: 'Jost',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Video list
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildVideoItem(),
                        const SizedBox(height: 10),
                        _buildVideoItem(),
                        const SizedBox(height: 10),
                        _buildVideoItem(),
                        const SizedBox(height: 10),
                        _buildVideoItem(),
                        const SizedBox(height: 10),
                        _buildVideoItem(),
                        const SizedBox(height: 10),
                        _buildVideoItem(),
                        
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
                ],
              ),
            ),
          ),
          
          // App bar
          Positioned(
            left: 0,
            top: 20,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Container(
                    width: 105,
                    height: 55,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage("https://placehold.co/105x55"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  // Menu dots
                  Container(
                    width: 55,
                    height: 58,
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-0.00, 0.92),
                        end: Alignment(1.00, 0.08),
                        colors: [const Color(0xFFDDF7FE), const Color(0xFFF7F7FA)],
                      ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0x194B92DB),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF3A567A),
                            shape: OvalBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF3A567A),
                            shape: OvalBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF3A567A),
                            shape: OvalBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Profile/Other icon
                  Container(
                    width: 59,
                    height: 58,
                    decoration: ShapeDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-0.00, 0.92),
                        end: Alignment(1.00, 0.08),
                        colors: [const Color(0xFFDDF7FE), const Color(0xFFF7F7FA)],
                      ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: const Color(0x194B92DB),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom navigation
          Positioned(
            left: 0,
            top: MediaQuery.of(context).size.height - 75, // Bottom of screen
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 75,
              color: const Color(0xFF3A567A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, color: const Color(0xFFFF7F00), size: 24),
                      const SizedBox(height: 4),
                      Text(
                        'Home',
                        style: TextStyle(
                          color: const Color(0xFFFF7F00),
                          fontSize: 11,
                          fontFamily: 'Kodchasan',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Column(
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
                  Column(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method for video items
  Widget _buildVideoItem() {
    return Container(
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