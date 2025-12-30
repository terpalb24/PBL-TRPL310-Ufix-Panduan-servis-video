// lib/screen/history.dart
import 'package:flutter/material.dart';
import 'package:ufix_mobile/models/history_video_model.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/services/storage_service.dart';
import 'package:ufix_mobile/screen/fakeplayer.dart';

// ============================================
// 1. Helper Widget (Define at TOP LEVEL, not inside _HistoryState)
// ============================================
class HistoryThumbnail extends StatelessWidget {
  final HistoryVideo video;
  final double width;
  final double height;

  const HistoryThumbnail({
    super.key,
    required this.video,
    this.width = 140,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = video.getThumbnailUrl();
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: thumbnailUrl.isNotEmpty
              ? NetworkImage(thumbnailUrl) as ImageProvider
              : const AssetImage('assets/images/Thumbnail-Fake.png') as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
      child: thumbnailUrl.isEmpty
          ? Center(
              child: Icon(
                Icons.videocam,
                color: Colors.white.withOpacity(0.7),
                size: 40,
              ),
            )
          : null,
    );
  }
}

// ============================================
// 2. Main History Widget (Stateful Widget)
// ============================================
class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

// ============================================
// 3. History State Class
// ============================================
class _HistoryState extends State<History> {
  List<HistoryVideo> _historyVideos = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _loadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    } else {
      setState(() {
        _loadingMore = true;
      });
    }

    try {
      final result = await ApiService.getHistory();
      
      if (result['success'] == true) {
        final videos = result['videos'] as List<dynamic>;
        
        if (loadMore) {
          setState(() {
            _historyVideos.addAll(
              videos.map((video) => HistoryVideo.fromJson(video)).toList(),
            );
            _hasMore = videos.length == _pageSize;
            _loadingMore = false;
            _currentPage++;
          });
        } else {
          setState(() {
            _historyVideos = videos.map((video) => HistoryVideo.fromJson(video)).toList();
            _hasMore = videos.length == _pageSize;
            _isLoading = false;
            _currentPage = 1;
          });
        }
      } else {
        if (result['needsLogin'] == true) {
          await _handleLogout();
          return;
        }
        
        setState(() {
          _hasError = true;
          _errorMessage = result['message'] ?? 'Failed to load history';
          _isLoading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Network error: $e';
        _isLoading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await StorageService.clearToken();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all your watch history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Clear All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final result = await ApiService.clearHistory();
        
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('History cleared successfully'),
              backgroundColor: Colors.green,
            ),
          );
          
          setState(() {
            _historyVideos.clear();
          });
        } else {
          if (result['needsLogin'] == true) {
            await _handleLogout();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to clear history'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onVideoTap(HistoryVideo historyVideo) {
    // Convert HistoryVideo to Video model for the player
    final video = historyVideo.toVideo();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoPlayerScreen(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A567A),
        foregroundColor: const Color(0xFFF7F7FA),
        elevation: 8,
        leading: Container(
          margin: const EdgeInsets.all(4),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_rounded),
          ),
        ),
        title: const Text(
          'History',
          style: TextStyle(
            color: Color(0xFFF7F7FA),
            fontFamily: 'Kodchasan',
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          if (_historyVideos.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Clear all history',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF3A567A),
            ),
            SizedBox(height: 16),
            Text(
              'Loading history...',
              style: TextStyle(
                color: Color(0xFF3A567A),
                fontFamily: 'Jost',
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Color(0xFF3A567A),
                fontSize: 16,
                fontFamily: 'Jost',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadHistory(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A567A),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jost',
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_historyVideos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No watch history yet',
              style: TextStyle(
                color: Color(0xFF3A567A),
                fontSize: 20,
                fontFamily: 'Kodchasan',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Videos you watch will appear here',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: 'Jost',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A567A),
              ),
              child: const Text(
                'Browse Videos',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jost',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Stats banner
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFEFF7FC),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Watched',
                    style: TextStyle(
                      color: const Color(0xFF3A567A),
                      fontSize: 14,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    '${_historyVideos.length} videos',
                    style: TextStyle(
                      color: const Color(0xFF3A567A),
                      fontSize: 20,
                      fontFamily: 'Kodchasan',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A567A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Last 30 days',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // History list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadHistory(),
            color: const Color(0xFF3A567A),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _historyVideos.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _historyVideos.length) {
                  return _buildLoadMoreButton();
                }
                
                final video = _historyVideos[index];
                return _buildHistoryItem(context, video);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(BuildContext context, HistoryVideo video) {
    return GestureDetector(
      onTap: () => _onVideoTap(video),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.98, -0.00),
            end: Alignment(0.02, 1.00),
            colors: [Color(0xFFEFF7FC), Color(0xFFF7F7FA)],
          ),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0x333A567A)),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          children: [
            // Use the helper widget
            HistoryThumbnail(video: video),
            const SizedBox(width: 11),
            // Video info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    video.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        video.formatWatchedDate(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    video.sentDate != null
                        ? 'Uploaded: ${video.sentDate!.day}/${video.sentDate!.month}/${video.sentDate!.year}'
                        : 'Upload date not available',
                    style: const TextStyle(
                      color: Colors.black54,
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
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    if (_loadingMore) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF3A567A),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _loadHistory(loadMore: true),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        width: 120,
        height: 36,
        decoration: ShapeDecoration(
          gradient: const LinearGradient(
            begin: Alignment(0.50, 1.00),
            end: Alignment(0.50, 0.00),
            colors: [
              Color(0xFFADE7F7),
              Color(0xFFF7F7FA),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Center(
          child: Text(
            'Load More',
            style: TextStyle(
              color: Color(0xFF3A567A),
              fontSize: 13,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}