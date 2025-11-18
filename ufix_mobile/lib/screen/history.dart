// lib/screens/history.dart
import 'package:flutter/material.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3A567A),
        foregroundColor: Color(0xFFF7F7FA),
        elevation: 8,

        leading: Container(
          margin: EdgeInsets.all(4),
          child: IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            icon: Icon(Icons.arrow_back_rounded),
          ),
        ),

        title: Text(
          'History',
          style: TextStyle(
            color: Color(0xFFF7F7FA),
            fontFamily: 'Kodchasan',
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // History list
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHistoryItem(context),
                    const SizedBox(height: 12),
                    _buildHistoryItem(context),
                    const SizedBox(height: 12),
                    _buildHistoryItem(context),
                    const SizedBox(height: 12),
                    _buildHistoryItem(context),
                    const SizedBox(height: 12),
                    _buildHistoryItem(context),
                    const SizedBox(height: 12),
                    _buildHistoryItem(context),
                    const SizedBox(height: 12),
                    _buildHistoryItem(context),
                    const SizedBox(height: 12),
                    _buildHistoryItem(context),
                    const SizedBox(height: 12),
                    _buildHistoryItem(context),

                    // Load more button
                    const SizedBox(height: 28),
                    Container(
                      width: 100,
                      height: 30,
                      decoration: ShapeDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(0.50, 1.00),
                          end: Alignment(0.50, 0.00),
                          colors: [
                            const Color(0xFFADE7F7),
                            const Color(0xFFF7F7FA),
                          ],
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF3A567A),
        selectedItemColor: Color(0XFFFF7F00),
        unselectedItemColor: Color(0XFFF7F7FA),
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

  // Helper method for history items
  Widget _buildHistoryItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/player');
      },
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
