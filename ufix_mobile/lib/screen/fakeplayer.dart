import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit;
import 'package:ufix_mobile/models/video_model.dart';
import 'package:ufix_mobile/screen/comments.dart';
import 'package:ufix_mobile/screen/bookmark.dart' show BookmarkApi;

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

  // state bookmark
  bool _isBookmarked = false;
  bool _bookmarkBusy = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initBookmarkState();
  }

  Future<void> _initBookmarkState() async {
    try {
      final marked = await BookmarkApi.isBookmarked(widget.video.idVideo);
      if (!mounted) return;
      setState(() {
        _isBookmarked = marked;
      });
    } catch (e) {
      debugPrint('Error cek bookmark: $e');
    }
  }

  Future<void> _toggleBookmark() async {
    if (_bookmarkBusy) return;

    setState(() {
      _bookmarkBusy = true;
    });

    try {
      if (_isBookmarked) {
        await BookmarkApi.removeBookmark(widget.video.idVideo);
        if (mounted) {
          setState(() => _isBookmarked = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bookmark dihapus')),
          );
        }
      } else {
        await BookmarkApi.addBookmark(widget.video.idVideo);
        if (mounted) {
          setState(() => _isBookmarked = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ditambahkan ke bookmark')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah bookmark: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _bookmarkBusy = false;
        });
      }
    }
  }

  Future<void> _initializeVideo() async {
    try {
      MediaKit.ensureInitialized();
      
      final videoUrl = 'http://10.0.2.2:3000/api/video/watch/${widget.video.idVideo}';
      print('🎬 Loading video from: $videoUrl');

      _mediaPlayer = Player();
      _videoController = media_kit.VideoController(_mediaPlayer!);

      await _mediaPlayer!.open(Media(videoUrl));

      _mediaPlayer!.stream.buffering.listen((isBuffering) {
        if (!isBuffering && mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
      });


      _mediaPlayer!.stream.playing.listen((isPlaying) {
        if (isPlaying && mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isLoading) {
          final state = _mediaPlayer!.state;
          if (state.playing && !state.buffering) {
            setState(() => _isLoading = false);
          }
        }
      });

      Future.delayed(const Duration(seconds: 15), () {
        if (_isLoading && mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      });
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
        title: Text(widget.video.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // button bookmark di kanan appbar
        actions: [
          IconButton(
            onPressed: _bookmarkBusy ? null : _toggleBookmark,
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0XFFFF7F00)),
                  SizedBox(height: 16),
                  Text(
                    'Loading video...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error,
                          color: Colors.white, size: 50),
                      const SizedBox(height: 16),
                      const Text(
                        'Video failed to load',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeVideo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0XFFFF7F00),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _videoController != null
                  ? Stack(
                      children: [
                        Positioned.fill(
                          child: media_kit.Video(
                            controller: _videoController!,
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 24,
                          child: FloatingActionButton(
                            heroTag: 'comments_btn',
                            backgroundColor: const Color(0XFFFF7F00),
                            child: const Icon(Icons.comment),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CommentsScreen(
                                      videoId: widget.video.idVideo),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Text(
                        'Video controller not available',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
    );
  }
}
