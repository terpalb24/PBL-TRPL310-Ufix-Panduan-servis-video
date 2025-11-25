// lib/screens/homepage.dart
import 'package:flutter/material.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/models/video_model.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Video> _videos = [];
  bool _isLoading = true;
  String _error = '';
  String _userName = 'User';
  int _selectedIndex = 0; // untuk bottom navigation

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _loadUserData();
  }

  Future<void> _loadVideos() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await ApiService.getNewVideos();
    
    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      final videosData = List<Map<String, dynamic>>.from(result['videos']);
      setState(() {
        _videos = videosData.map((videoData) => Video.fromJson(videoData)).toList();
      });
    } else {
      setState(() {
        _error = result['message'];
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _userName = 'User';
    });
  }

  void _navigateToVideoPlayer(Video video) {
    Navigator.pushNamed(
      context, 
      '/player',
      arguments: video,
    );
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home'); // halaman homepage
        break;
      case 1:
        Navigator.pushNamed(context, '/search'); // halaman search
        break;
      case 2:
        Navigator.pushNamed(context, '/bookmark'); // halaman bookmark
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF7F7FA),
        foregroundColor: Color(0xFF3A567A),
        elevation: 4,
        leading: Container(
          margin: EdgeInsets.all(8),
          child: Image.asset(
            'Asset/logo.png',
            width: 210,
            height: 110,
          ),
        ),
        title: SizedBox.shrink(),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            icon: Icon(Icons.history),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: const Color(0xFFF7F7FA)),
          ),
          CustomScrollView(
            slivers: [
              // Banner dan video list tetap sama
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
                        'Welcome, $_userName!',
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
              // Tabs
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
                            border: Border.all(width: 1, color: const Color(0xFF3A567A)),
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
                              border: Border.all(width: 1, color: const Color(0xFF3A567A)),
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
              if (_isLoading)
                SliverToBoxAdapter(
                  child: Container(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF3A567A)),
                    ),
                  ),
                )
              else if (_error.isNotEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: $_error',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadVideos,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == _videos.length) {
                        return Container(
                          width: 100,
                          height: 30,
                          margin: EdgeInsets.all(20),
                          decoration: ShapeDecoration(
                            gradient: LinearGradient(
                              begin: Alignment(0.50, 1.00),
                              end: Alignment(0.50, 0.00),
                              colors: [Color(0xFFADE7F7), Color(0xFFF7F7FA)],
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
                        padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                        child: _buildVideoItem(context, _videos[index]),
                      );
                    },
                    childCount: _videos.length + 1,
                  ),
                ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
        ],
        selectedItemColor: Color(0xFF3A567A),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildVideoItem(BuildContext context, Video video) {
    return GestureDetector(
      onTap: () => _navigateToVideoPlayer(video),
      child: Container(
        width: double.infinity,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.98, -0.00),
            end: Alignment(0.02, 1.00),
            colors: [Color(0xFFEFF7FC), Color(0xFFF7F7FA)],
          ),
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: Color(0x333A567A)),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 140,
              height: 80,
              decoration: ShapeDecoration(
                image: DecorationImage(
                  image: _getThumbnailImage(video.thumbnailPath),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    video.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _getUploaderText(video.uploader),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    _formatDuration(video.durationSec),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    _formatDate(video.sentDate),
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

  ImageProvider _getThumbnailImage(String thumbnailPath) {
    if (thumbnailPath.startsWith('http')) {
      return NetworkImage(thumbnailPath);
    } else if (thumbnailPath.isNotEmpty) {
      return AssetImage(thumbnailPath);
    } else {
      return AssetImage('Asset/Thumbnail-Fake.png');
    }
  }

  String _getUploaderText(int? uploader) {
    return uploader != null ? 'User $uploader' : 'Unknown Uploader';
  }

  String _formatDuration(int? durationSec) {
    if (durationSec == null) return 'Duration: Unknown';
    final duration = Duration(seconds: durationSec);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return 'Duration: ${minutes}m ${seconds}s';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date unknown';
    return 'Uploaded: ${date.day}/${date.month}/${date.year}';
  }
}
