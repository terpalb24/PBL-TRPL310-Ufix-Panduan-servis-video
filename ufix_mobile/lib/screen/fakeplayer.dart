import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' as media_kit;
import 'package:ufix_mobile/models/video_model.dart';
import 'package:ufix_mobile/screen/comments.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      // Initialize MediaKit first! - NO AWAIT needed
      MediaKit.ensureInitialized();
      
      final videoUrl = 'http://localhost:3000/api/video/watch/${widget.video.idVideo}';
      print('🎬 Loading video from: $videoUrl');

      _mediaPlayer = Player();
      _videoController = media_kit.VideoController(_mediaPlayer!);

      await _mediaPlayer!.open(Media(videoUrl));

      // Listen for when video starts playing
      _mediaPlayer!.streams.buffering.listen((isBuffering) {
        print('📊 Buffering: $isBuffering');
        if (!isBuffering && mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
      });

      // Listen for when video is actually playing
      _mediaPlayer!.streams.playing.listen((isPlaying) {
        print('▶️ Playing: $isPlaying');
        if (isPlaying && mounted && _isLoading) {
          setState(() => _isLoading = false);
        }
      });

      // Check current state after a short delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isLoading) {
          final state = _mediaPlayer!.state;
          print('📺 Player state - playing: ${state.playing}, buffering: ${state.buffering}');
          if (state.playing && !state.buffering) {
            setState(() => _isLoading = false);
          }
        }
      });

      // Timeout
      Future.delayed(const Duration(seconds: 15), () {
        if (_isLoading && mounted) {
          print('⏰ Video loading timeout');
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
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0XFFFF7F00)),
                  SizedBox(height: 16),
                  Text('Loading video...', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.white, size: 50),
                      const SizedBox(height: 16),
                      const Text('Video failed to load', style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _initializeVideo,
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0XFFFF7F00)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _videoController != null
                  ? Stack(
                      children: [
                        Positioned.fill(child: media_kit.Video(controller: _videoController!)),
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
                                MaterialPageRoute(builder: (_) => CommentsScreen(videoId: widget.video.idVideo)),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : const Center(child: Text('Video controller not available', style: TextStyle(color: Colors.white))),
    );
  }
}