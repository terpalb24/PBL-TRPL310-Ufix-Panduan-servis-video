// lib/screens/homepage.dart
import 'package:flutter/material.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/services/auth_manager.dart';
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
  String _debugInfo = 'Initializing...'; // Add debug info string

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
      _debugInfo = 'Starting API call...';
    });

    try {
      _debugInfo = 'Calling API...';
      final result = await ApiService.getNewVideos();
      
      _debugInfo = 'API response received. Success: ${result['success']}';
      
      if (result['success'] == true) {
        final videosData = result['videos'] as List<dynamic>?;
        _debugInfo = 'Videos data: ${videosData?.length ?? 0} items';
        
        if (videosData != null && videosData.isNotEmpty) {
          final List<Video> parsedVideos = [];
          
          for (final videoData in videosData) {
            try {
              final video = Video.fromJson(Map<String, dynamic>.from(videoData));
              parsedVideos.add(video);
              _debugInfo = 'Parsed video: ID ${video.idVideo}, Title: ${video.title}';
            } catch (e) {
              _debugInfo = 'Error parsing video: $e';
            }
          }
          
          setState(() {
            _videos = parsedVideos;
            _isLoading = false;
            _debugInfo = 'Loaded ${_videos.length} videos successfully';
          });
        } else {
          setState(() {
            _isLoading = false;
            _error = 'No videos found in response';
            _debugInfo = 'No videos in API response';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _error = result['message'] ?? 'Failed to load videos';
          _debugInfo = 'API returned error: $_error';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error loading videos: $e';
        _debugInfo = 'Exception: $e';
      });
    }
  }

  Future<void> _loadUserData() async {
    setState(() {
      _userName = AuthManager.currentUser?.displayName ?? 'User';
    });
  }

  void _navigateToVideoPlayer(Video video) {
    Navigator.pushNamed(
      context, 
      '/player',
      arguments: video,
    );
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
      body: Column(
        children: [
          // DEBUG BANNER - This will show what's happening
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            color: Colors.orange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEBUG INFO:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  _debugInfo,
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
                Text(
                  'Videos loaded: ${_videos.length}, Loading: $_isLoading, Error: $_error',
                  style: TextStyle(color: Colors.black, fontSize: 10),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                // Background
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
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

                    // Tab section
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
                    if (_isLoading)
                      SliverToBoxAdapter(
                        child: Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFF3A567A),
                                ),
                                SizedBox(height: 16),
                                Text('Loading videos...'),
                              ],
                            ),
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
                                Icon(Icons.error, color: Colors.red, size: 50),
                                SizedBox(height: 16),
                                Text(
                                  'Error: $_error',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadVideos,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF3A567A),
                                  ),
                                  child: Text(
                                    'Retry',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else if (_videos.isEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.videocam_off, color: Colors.grey, size: 50),
                                SizedBox(height: 16),
                                Text(
                                  'No videos available',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadVideos,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF3A567A),
                                  ),
                                  child: Text(
                                    'Refresh',
                                    style: TextStyle(color: Colors.white),
                                  ),
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
                            final video = _videos[index];
                            return Padding(
                              padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
                              child: _buildVideoItem(context, video),
                            );
                          },
                          childCount: _videos.length,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildVideoItem(BuildContext context, Video video) {
  return GestureDetector(
    onTap: () {
      _navigateToVideoPlayer(video);
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
          // Thumbnail with better error handling
          _buildThumbnailWidget(video.thumbnailPath),
          const SizedBox(width: 11),
          // Video info
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

// Separate method for thumbnail with proper error handling
Widget _buildThumbnailWidget(String thumbnailPath) {
  return Container(
    width: 140,
    height: 80,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.grey[300], // Fallback background color
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: _buildThumbnailImage(thumbnailPath),
    ),
  );
}

// Separate method for image with error handling
Widget _buildThumbnailImage(String thumbnailPath) {
  String imageUrl = _constructImageUrl(thumbnailPath);
  
  return Image.network(
    imageUrl,
    fit: BoxFit.cover,
    loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF3A567A),
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        ),
      );
    },
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: Colors.grey[300],
        child: Icon(
          Icons.videocam,
          color: Colors.grey[600],
          size: 40,
        ),
      );
    },
  );
}

// Helper method to construct image URL
String _constructImageUrl(String thumbnailPath) {
  if (thumbnailPath.startsWith('http')) {
    return thumbnailPath;
  } else if (thumbnailPath.isNotEmpty) {
    return 'http://localhost:3000$thumbnailPath';
  } else {
    // Return a placeholder image URL or use asset
    return 'http://localhost:3000/placeholder.jpg'; // Fallback
  }
}

  ImageProvider _getThumbnailImage(String thumbnailPath) {
    if (thumbnailPath.startsWith('http')) {
      return NetworkImage(thumbnailPath);
    } else if (thumbnailPath.isNotEmpty) {
      return NetworkImage('http://localhost:3000$thumbnailPath');
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
    return '${minutes}m ${seconds}s';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}