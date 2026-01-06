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
  List<Video> _newVideos = [];
  List<Video> _watchedVideos = [];
  Map<int, bool> _bookmarkedStatus = {};
  bool _isLoadingNewVideos = true;
  bool _isLoadingWatchedVideos = true;
  bool _isLoadingBookmarks = false;
  String _errorNewVideos = '';
  String _errorWatchedVideos = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _loadNewVideos(),
      _loadWatchedVideos(),
    ]);
  }

  Future<void> _loadNewVideos() async {
    setState(() {
      _isLoadingNewVideos = true;
      _errorNewVideos = '';
    });

    try {
      final result = await ApiService.getNewVideos();
      
      if (result['success'] == true) {
        final videosData = result['videos'] as List<dynamic>?;
        
        if (videosData != null && videosData.isNotEmpty) {
          final List<Video> parsedVideos = [];
          
          for (final videoData in videosData) {
            try {
              final video = Video.fromJson(Map<String, dynamic>.from(videoData));
              parsedVideos.add(video);
            } catch (e) {
              print('Error parsing video: $e');
            }
          }
          
          setState(() {
            _newVideos = parsedVideos;
            _isLoadingNewVideos = false;
          });
          
          // Load bookmark status for new videos
          _loadBookmarkStatus(parsedVideos);
        } else {
          setState(() {
            _isLoadingNewVideos = false;
            _errorNewVideos = 'No new videos found';
          });
        }
      } else {
        setState(() {
          _isLoadingNewVideos = false;
          _errorNewVideos = result['message'] ?? 'Failed to load new videos';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingNewVideos = false;
        _errorNewVideos = 'Error loading videos: $e';
      });
    }
  }

  Future<void> _loadWatchedVideos() async {
    setState(() {
      _isLoadingWatchedVideos = true;
      _errorWatchedVideos = '';
    });

    try {
      final result = await ApiService.getHistory();
      
      if (result['success'] == true) {
        final historyData = result['history'] as List<dynamic>?;
        
        if (historyData != null && historyData.isNotEmpty) {
          final List<Video> parsedVideos = [];
          
          for (final historyItem in historyData) {
            try {
              // Extract video data from history item
              final videoData = historyItem['video'] ?? historyItem;
              final video = Video.fromJson(Map<String, dynamic>.from(videoData));
              parsedVideos.add(video);
            } catch (e) {
              print('Error parsing history video: $e');
            }
          }
          
          setState(() {
            _watchedVideos = parsedVideos;
            _isLoadingWatchedVideos = false;
          });
          
          // Load bookmark status for watched videos
          _loadBookmarkStatus(parsedVideos);
        } else {
          setState(() {
            _isLoadingWatchedVideos = false;
            _errorWatchedVideos = 'No watch history found';
          });
        }
      } else {
        setState(() {
          _isLoadingWatchedVideos = false;
          _errorWatchedVideos = result['message'] ?? 'Failed to load history';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingWatchedVideos = false;
        _errorWatchedVideos = 'Error loading history: $e';
      });
    }
  }

  Future<void> _loadUserData() async {
    final currentUser = AuthManager.currentUser;
    
    if (currentUser != null && currentUser.displayName.isNotEmpty) {
      setState(() {
        _userName = currentUser.displayName;
      });
    } else {
      // Fallback: Try to get from API
      try {
        final profileResult = await ApiService.getProfile();
        if (profileResult['success'] == true && profileResult['user'] != null) {
          final userData = profileResult['user'] as Map<String, dynamic>;
          setState(() {
            _userName = userData['displayName'] ?? 'User';
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
    
    // Ensure we have at least "User" as fallback
    if (_userName.isEmpty) {
      setState(() {
        _userName = 'User';
      });
    }
  }

  Future<void> _loadBookmarkStatus(List<Video> videos) async {
    setState(() {
      _isLoadingBookmarks = true;
    });

    try {
      for (final video in videos) {
        final isBookmarked = await ApiService.isBookmarked(video.idVideo);
        setState(() {
          _bookmarkedStatus[video.idVideo] = isBookmarked;
        });
      }
    } catch (e) {
      print('Error loading bookmark status: $e');
    } finally {
      setState(() {
        _isLoadingBookmarks = false;
      });
    }
  }

  Future<void> _toggleBookmark(Video video) async {
    final videoId = video.idVideo;
    final isCurrentlyBookmarked = _bookmarkedStatus[videoId] ?? false;
    
    setState(() {
      _bookmarkedStatus[videoId] = !isCurrentlyBookmarked;
    });

    try {
      if (isCurrentlyBookmarked) {
        await ApiService.removeBookmark(videoId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from bookmarks'),
            backgroundColor: Color(0xFF3A567A),
          ),
        );
      } else {
        await ApiService.addBookmark(videoId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to bookmarks'),
            backgroundColor: Color(0xFF3A567A),
          ),
        );
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _bookmarkedStatus[videoId] = isCurrentlyBookmarked;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update bookmark: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToVideoPlayer(Video video) {
    Navigator.pushNamed(
      context, 
      '/player',
      arguments: video,
    );
  }

  Widget _buildVideoCard(Video video, {double width = 160, double height = 240}) {
    final isBookmarked = _bookmarkedStatus[video.idVideo] ?? false;
    
    return GestureDetector(
      onTap: () => _navigateToVideoPlayer(video),
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 18),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: ShapeDecoration(
          color: const Color(0xFFFFF7F7),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFF3A567A)),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildThumbnailImage(video.thumbnailPath),
                  ),
                ),
                const SizedBox(height: 8),
                // Title
                Text(
                  video.title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                // Date
                const SizedBox(height: 4),
                Text(
                  _formatDate(video.sentDate),
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            // Bookmark Button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _toggleBookmark(video),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: const Color(0xFF3A567A),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              color: const Color(0xFF3A567A),
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
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam,
                color: Colors.grey,
                size: 40,
              ),
              SizedBox(height: 8),
              Text(
                'No Thumbnail',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _constructImageUrl(String thumbnailPath) {
    if (thumbnailPath.startsWith('http')) {
      return thumbnailPath;
    } else if (thumbnailPath.isNotEmpty) {
      return '${ApiService.baseUrl.replaceFirst('/api', '')}$thumbnailPath';
    } else {
      return '${ApiService.baseUrl.replaceFirst('/api', '')}/placeholder.jpg';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date unknown';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Widget _buildVideoSection({
    required String title,
    required List<Video> videos,
    required bool isLoading,
    required String error,
    required VoidCallback onRefresh,
    VoidCallback? onSeeMore,
    bool showBookmarks = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF3A567A),
                  fontSize: 20,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onSeeMore != null)
                GestureDetector(
                  onTap: onSeeMore,
                  child: Row(
                    children: [
                      const Text(
                        'See More',
                        style: TextStyle(
                          color: Color(0xFF3A567A),
                          fontSize: 14,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 18,
                        height: 18,
                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF3A567A),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content
          if (isLoading)
            Container(
              height: 240,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: Color(0xFF3A567A)),
            )
          else if (error.isNotEmpty)
            Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3A567A), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A567A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          else if (videos.isEmpty)
            Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3A567A), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off, color: Colors.grey, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'No videos available',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: onRefresh,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A567A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Refresh',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 240,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return _buildVideoCard(videos[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7FA),
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: Image.asset(
            'Asset/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        title: const SizedBox.shrink(),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
            icon: const Icon(Icons.history, color: Color(0xFF3A567A)),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/bookmarks');
            },
            icon: const Icon(Icons.bookmark, color: Color(0xFF3A567A)),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(Icons.settings, color: Color(0xFF3A567A)),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF3A567A),
        onRefresh: () async {
          await _loadAllData();
        },
        child: ListView(
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF3A567A).withOpacity(0.9),
                    const Color(0xFF4B92DB),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $_userName! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'Kodchasan',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Continue your learning journey',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Quick Actions Row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/bookmarks');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF3A567A),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.bookmark),
                          label: const Text('Bookmarks'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/search');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF3A567A),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.search),
                          label: const Text('Search'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            const Divider(height: 1, color: Color(0xFFE0E0E0)),

            // Last Watched Videos Section
            _buildVideoSection(
              title: 'Continue Watching',
              videos: _watchedVideos,
              isLoading: _isLoadingWatchedVideos,
              error: _errorWatchedVideos,
              onRefresh: _loadWatchedVideos,
              onSeeMore: () {
                Navigator.pushNamed(context, '/history');
              },
            ),

            // Divider
            const Divider(height: 1, color: Color(0xFFE0E0E0)),

            // New Videos Section
            _buildVideoSection(
              title: 'New Videos',
              videos: _newVideos,
              isLoading: _isLoadingNewVideos,
              error: _errorNewVideos,
              onRefresh: _loadNewVideos,
              onSeeMore: () {
                Navigator.pushNamed(context, '/new-videos');
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}