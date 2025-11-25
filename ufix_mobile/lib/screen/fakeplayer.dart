// lib/screens/fake_player.dart
import 'package:flutter/material.dart';
import "package:video_player/video_player.dart";
import 'package:chewie/chewie.dart';

class Player extends StatefulWidget {
  final String url_video;
  final String judul_video;

  const Player({
    super.key,
    required this.url_video,
    required this.judul_video,
  });

  @override
  State<Player> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<Player> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.url_video));
    
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      placeholder: Container(color: Colors.black),
      materialProgressColors: ChewieProgressColors(
        playedColor: Color(0XFFFF7F00),
        handleColor: Color(0XFFFF7F00),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.grey.shade300,
      ),
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.judul_video),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0XFFFF7F00)))
          : Chewie(controller: _chewieController),
    );
  }
}
