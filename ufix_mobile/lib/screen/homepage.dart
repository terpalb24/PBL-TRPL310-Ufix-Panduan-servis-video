// lib/screens/homepage.dart
import 'package:flutter/material.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //App bar home page, Jauharil
        backgroundColor: Color(0xFFF7F7FA),
        foregroundColor: Color(0xFF3A567A),
        elevation: 4,

        leading: Container(
          margin: EdgeInsets.all(8),
          child: Image.asset(
            'Asset/logo.png',
            width: 210,
            height: 110,
          ), // Logo, align kiri
        ),
        title: SizedBox.shrink(),
        centerTitle: true,

        actions: [
          IconButton(onPressed: () {Navigator.pushNamed(context, '/history');}, icon: Icon(Icons.history)), //Tombol History
          IconButton(onPressed: () {Navigator.pushNamed(context, '/settings');}, icon: Icon(Icons.settings)), //Tombol Settings
        ],
      ),
      body: Stack(
  children: [
    // Background (covers entire screen, fixed)
    Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(color: const Color(0xFFF7F7FA)),
    ),

    // Scrollable content
    CustomScrollView(
      slivers: [
        // Welcome banner section
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            height: 400,
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
                      image: AssetImage('Asset/Thumbnail-Fake.png'),
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
        ),

        // Tab buttons section
        SliverToBoxAdapter(
          child: SizedBox(
            width: double.infinity,
            child: Row(
              children: [
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
        ),

        // Video list section
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 6) { // Load more button after 6 videos
                return Container(
                  width: 60,
                  height: 30,
                  margin: EdgeInsets.all(20),
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
                );
              }
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, index == 5 ? 10 : 0),
                child: _buildVideoItem(),
              );
            },
            childCount: 7, // 6 videos + 1 load more button
          ),
        ),
      ],
    ),
  ],
),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF3A567A),
        selectedItemColor: Color(0XFFFF7F00),
        unselectedItemColor: Color(0XFFF7F7FA),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home),activeIcon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search),activeIcon: Icon(Icons.search), label: 'search'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark),activeIcon: Icon(Icons.bookmark), label: 'bookmark')
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
                GestureDetector(
                    onTap: () {
                    },
                    
                  ),
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