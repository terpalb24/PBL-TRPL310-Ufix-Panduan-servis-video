import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit;
import 'package:ufix_mobile/models/video_model.dart';
import 'package:ufix_mobile/screen/comments.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/services/storage_service.dart';
import 'package:ufix_mobile/screen/description.dart'; // Add this import

class VideoPlayerScreen extends StatefulWidget {
  final Video video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  Player? _mediaPlayer;
  media_kit.VideoController? _videoController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isBookmarked = false;
  bool _bookmarkBusy = false;
  String? _videoDescription; // Store the video deskripsi

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _checkBookmarkStatus();
    _loadVideoDescription(); // Load deskripsi when screen initializes
  }

  Future<void> _loadVideoDescription() async {
    try {
      final result = await ApiService.getVideoDescription(widget.video.idVideo);
      if (result['success'] == true) {
        setState(() {
          _videoDescription = result['video']['deskripsi'];
        });
      }
    } catch (e) {
      print('Error loading video deskripsi: $e');
      // Don't show error for deskripsi, just leave it null
    }
  }

  // In your VideoPlayerScreen, when using the thumbnail
  ImageProvider getThumbnailImageProvider() {
    if (widget.video.thumbnailPath.isNotEmpty) {
      return NetworkImage(widget.video.thumbnailPath);
    }
    return const AssetImage('assets/images/placeholder_thumbnail.png');
  }

  Future<void> _initializeVideo() async {
    try {
      MediaKit.ensureInitialized();

      print('🎬 Requesting stream URL for video ID: ${widget.video.idVideo}');

      // Get the pre-signed stream URL from API
      final streamResponse = await ApiService.getVideoStreamUrl(
        widget.video.idVideo,
      );

      if (streamResponse['success'] == true) {
        final videoData = streamResponse['video'];
        final videoUrl = videoData['videoUrl'];

        print('✅ Got stream URL: $videoUrl');
        print('Video details: ${videoData['judul']}');

        _mediaPlayer = Player();
        _videoController = media_kit.VideoController(_mediaPlayer!);
        await _mediaPlayer!.open(Media(videoUrl));

        // Set loading to false after video starts
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _isLoading) {
            setState(() => _isLoading = false);
          }
        });
      } else {
        print('❌ Failed to get stream URL: ${streamResponse['message']}');

        if (streamResponse['needsLogin'] == true) {
          await _handleLogout();
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      print('💥 Video initialization error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _checkBookmarkStatus() async {
    try {
      final result = await ApiService.isBookmarked(widget.video.idVideo);
      if (mounted) {
        setState(() => _isBookmarked = result);
      }
    } catch (e) {
      print('Error checking bookmark status: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    if (_bookmarkBusy) return;

    setState(() => _bookmarkBusy = true);

    try {
      final result = _isBookmarked
          ? await ApiService.removeBookmark(widget.video.idVideo)
          : await ApiService.addBookmark(widget.video.idVideo);

      if (result['success'] == true) {
        setState(() => _isBookmarked = !_isBookmarked);
        _showSnackBar(result['message'] ?? 'Bookmark updated');
      } else if (result['needsLogin'] == true) {
        await _handleLogout();
        _showSnackBar('Please login to bookmark videos');
      } else {
        _showSnackBar(result['message'] ?? 'Failed to update bookmark');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _bookmarkBusy = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    await StorageService.clearToken();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              message.contains('Added') || message.contains('Removed')
                  ? Colors.green
                  : Colors.red,
        ),
      );
    }
  }

  void _navigateToDescription() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VideoDescriptionScreen(
          videoId: widget.video.idVideo,
          videoTitle: widget.video.title,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mediaPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.video.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Description button
          IconButton(
            onPressed: _navigateToDescription,
            icon: const Icon(Icons.description),
            tooltip: 'View Description',
          ),
          IconButton(
            onPressed: _bookmarkBusy ? null : _toggleBookmark,
            icon: _bookmarkBusy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                  ),
            tooltip: _isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
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
            CircularProgressIndicator(color: Color(0XFFFF7F00)),
            SizedBox(height: 16),
            Text('Loading video...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Failed to load video',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              widget.video.title,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeVideo,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFFFF7F00),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (_videoController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.white, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Video player unavailable',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeVideo,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _buildVideoPlayer();
  }

  Widget _buildVideoPlayer() {
    return Stack(
      children: [
        Positioned.fill(child: media_kit.Video(controller: _videoController!)),

        // Video title overlay
        Positioned(
          left: 16,
          top: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_videoDescription != null &&
                    _videoDescription!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    child: Text(
                      _videoDescription!.length > 100
                          ? '${_videoDescription!.substring(0, 100)}...'
                          : _videoDescription!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Show more deskripsi button
        if (_videoDescription != null && _videoDescription!.isNotEmpty)
          Positioned(
            left: 16,
            top: 100, // Adjust position based on your layout
            child: GestureDetector(
              onTap: _navigateToDescription,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0XFFFF7F00).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Full Description',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Comments button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'comments_btn',
            backgroundColor: const Color(0XFFFF7F00),
            child: const Icon(Icons.comment),
            onPressed: () {
              _navigateToComments();
            },
          ),
        ),

        // Quick deskripsi button
        Positioned(
          right: 16,
          bottom: 80,
          child: FloatingActionButton(
            heroTag: 'deskripsi_btn',
            backgroundColor: const Color(0xFF3A567A),
            mini: true,
            child: const Icon(Icons.description),
            onPressed: _navigateToDescription,
          ),
        ),
      ],
    );
  }

  void _navigateToComments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommentsScreen(videoId: widget.video.idVideo),
      ),
    );
  }
}