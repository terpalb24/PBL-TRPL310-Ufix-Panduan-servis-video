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
      print('DEBUG: New videos result: ${result['success']}');
      
      if (result['success'] == true) {
        final videosData = result['videos'] as List<dynamic>?;
        print('DEBUG: Videos data count: ${videosData?.length}');
        
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
      print('Error loading new videos: $e');
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
      print('DEBUG: History result: ${result['success']}');
      print('DEBUG: History data: $result');
      
      if (result['success'] == true) {
        // Try different possible response structures
        dynamic videosData;
        
        if (result['videos'] != null) {
          videosData = result['videos'];
        } else if (result['history'] != null) {
          videosData = result['history'];
        } else if (result['data'] != null) {
          videosData = result['data'];
        }
        
        print('DEBUG: Found videosData: ${videosData != null}');
        
        if (videosData is List && videosData.isNotEmpty) {
          final List<Video> parsedVideos = [];
          
          for (final item in videosData) {
            try {
              // Handle different response structures
              dynamic videoData;
              
              if (item is Map<String, dynamic>) {
                // Check if item has a 'video' field (nested structure)
                if (item.containsKey('video') && item['video'] != null) {
                  videoData = item['video'];
                } else {
                  videoData = item;
                }
              }
              
              if (videoData != null && videoData is Map<String, dynamic>) {
                final video = Video.fromJson(videoData);
                parsedVideos.add(video);
              }
            } catch (e) {
              print('Error parsing history item: $e, item: $item');
            }
          }
          
          print('DEBUG: Parsed ${parsedVideos.length} watched videos');
          
          setState(() {
            _watchedVideos = parsedVideos;
            _isLoadingWatchedVideos = false;
          });
          
          // Load bookmark status for watched videos
          _loadBookmarkStatus(parsedVideos);
        } else {
          print('DEBUG: No watched videos data or empty list');
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
      print('Error loading watched videos: $e');
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
      print('DEBUG: Loaded user name from AuthManager: $_userName');
    } else {
      // Fallback: Try to get from API
      try {
        final profileResult = await ApiService.getProfile();
        if (profileResult['success'] == true && profileResult['user'] != null) {
          final userData = profileResult['user'] as Map<String, dynamic>;
          setState(() {
            _userName = userData['displayName'] ?? 'User';
          });
          print('DEBUG: Loaded user name from API: $_userName');
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
    if (videos.isEmpty) return;
    
    try {
      for (final video in videos) {
        try {
          final isBookmarked = await ApiService.isBookmarked(video.idVideo);
          if (mounted) {
            setState(() {
              _bookmarkedStatus[video.idVideo] = isBookmarked;
            });
          }
        } catch (e) {
          print('Error loading bookmark status for video ${video.idVideo}: $e');
        }
      }
    } catch (e) {
      print('Error loading bookmark status: $e');
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
        final result = await ApiService.removeBookmark(videoId);
        if (result['success'] != true) {
          // Revert on error
          setState(() {
            _bookmarkedStatus[videoId] = isCurrentlyBookmarked;
          });
          throw Exception(result['message'] ?? 'Failed to remove bookmark');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from bookmarks'),
            backgroundColor: Color(0xFF3A567A),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        final result = await ApiService.addBookmark(videoId);
        if (result['success'] != true) {
          // Revert on error
          setState(() {
            _bookmarkedStatus[videoId] = isCurrentlyBookmarked;
          });
          throw Exception(result['message'] ?? 'Failed to add bookmark');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to bookmarks'),
            backgroundColor: Color(0xFF3A567A),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
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
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: const Color(0xFF3A567A)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                // Thumbnail Container
                Container(
                  width: double.infinity,
                  height: 140, // Reduced to accommodate text better
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildThumbnailImage(video.thumbnailPath),
                  ),
                ),
                const SizedBox(height: 10),
                
                // Title with proper overflow handling
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Title Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.title,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14, // Slightly smaller font
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.3, // Better line height
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                        
                        // Date at the bottom
                        Text(
                          _formatDate(video.sentDate),
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 11, // Slightly smaller
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
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
                    size: 18, // Slightly smaller icon
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
                size: 30,
              ),
              SizedBox(height: 4),
              Text(
                'No Thumbnail',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
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
      // Check if it already starts with a slash
      if (thumbnailPath.startsWith('/')) {
        return '${ApiService.baseUrl.replaceFirst('/api', '')}$thumbnailPath';
      } else {
        return '${ApiService.baseUrl.replaceFirst('/api', '')}/$thumbnailPath';
      }
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
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF3A567A),
                    fontSize: 20,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onSeeMore != null && videos.isNotEmpty)
                GestureDetector(
                  onTap: onSeeMore,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF3A567A), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'See More',
                          style: TextStyle(
                            color: Color(0xFF3A567A),
                            fontSize: 14,
                            fontFamily: 'Jost',
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3A567A), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 12),
                  Flexible(
                    child: Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
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
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3A567A), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.videocam_off, color: Colors.grey, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'No videos available',
                    style: TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('Asset/bg-app.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFF3A567A),
            onRefresh: () async {
              await _loadAllData();
            },
            child: ListView(
              children: [
                // AppBar Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: const Color(0xFF3A567A), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.asset(
                            'Asset/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Welcome Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                color: const Color(0xFF3A567A),
                                fontSize: 14,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _userName,
                              style: const TextStyle(
                                color: Color(0xFF3A567A),
                                fontSize: 18,
                                fontFamily: 'Kodchasan',
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Action Icons
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/history');
                        },
                        icon: const Icon(Icons.history, color: Color(0xFF3A567A), size: 28),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/bookmark');
                        },
                        icon: const Icon(Icons.bookmark, color: Color(0xFF3A567A), size: 28),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                        icon: const Icon(Icons.person, color: Color(0xFF3A567A), size: 28),
                      ),
                    ],
                  ),
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: const Color(0xFF3A567A).withOpacity(0.3),
                    thickness: 1,
                  ),
                ),

                // Last Watched Videos Section
                _buildVideoSection(
                  title: 'Continue Watching',
                  videos: _watchedVideos,
                  isLoading: _isLoadingWatchedVideos,
                  error: _errorWatchedVideos,
                  onRefresh: _loadWatchedVideos,
                  onSeeMore: _watchedVideos.isNotEmpty ? () {
                    Navigator.pushNamed(context, '/history');
                  } : null,
                ),

                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 1,
                    color: const Color(0xFF3A567A).withOpacity(0.3),
                    thickness: 1,
                  ),
                ),

                // New Videos Section
                _buildVideoSection(
                  title: 'New Videos',
                  videos: _newVideos,
                  isLoading: _isLoadingNewVideos,
                  error: _errorNewVideos,
                  onRefresh: _loadNewVideos,
                  onSeeMore: _newVideos.isNotEmpty ? () {
                    Navigator.pushNamed(context, '/new-videos');
                  } : null,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}