// lib/screens/searched.dart
import 'package:flutter/material.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/models/video_model.dart';

class SearchedVideos extends StatefulWidget {
  const SearchedVideos({super.key});

  @override
  State<SearchedVideos> createState() => _SearchedVideosState();
}

class _SearchedVideosState extends State<SearchedVideos> {
  bool _initialized = false;
  bool _isLoading = true;
  String _error = '';
  String _query = '';
  List<Video> _videos = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map && args['query'] is String) {
        _query = (args['query'] as String).trim();
      }
      _searchVideos();
      _initialized = true;
    }
  }

  void _navigateToVideoPlayer(Video video) {
    Navigator.pushNamed(context, '/player', arguments: video);
  }

  Future<void> _searchVideos() async {
    if (_query.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Kata kunci pencarian tidak ditemukan.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    final result = await ApiService.searchVideos(_query);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success'] == true && result['videos'] is List) {
        final videosList = result['videos'] as List;
        _videos = videosList.map((videoData) {
          return Video.fromJson(videoData);
        }).toList();
      } else {
        _error =
            result['message']?.toString() ?? 'Gagal memuat hasil pencarian';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: const Color(0xFFF7F7FA),
          ),

          SafeArea(
            child: Column(
              children: [
                // TOP BAR
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Hasil Pencarian',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontFamily: 'Kodchasan',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Query & filter info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _query.isEmpty ? '' : '"$_query"',
                          style: const TextStyle(
                            color: Color(0xFF3A567A),
                            fontSize: 12,
                            fontFamily: 'Jost',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildActiveFilterChip('Semua'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Body
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildBody(),
                  ),
                ),

                if (!_isLoading && _error.isEmpty && _videos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: _searchVideos,
                      child: Container(
                        width: 120,
                        height: 32,
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(0.50, 1.00),
                            end: Alignment(0.50, 0.00),
                            colors: [Color(0xFFADE7F7), Color(0xFFF7F7FA)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Muat Ulang',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF3A567A)),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 13,
                fontFamily: 'Jost',
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _searchVideos,
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }

    if (_videos.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada video yang cocok.',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _videos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final video = _videos[index];
        return _buildVideoResultItem(video);
      },
    );
  }

  Widget _buildActiveFilterChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: ShapeDecoration(
        color: const Color(0xFFF7F7FA),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF3A567A)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.check, size: 14, color: Color(0xFF3A567A)),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoResultItem(Video video) {
    return GestureDetector(
      onTap: () {
        _navigateToVideoPlayer(video);
      },
      child: Container(
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
            // Thumbnail
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
                    style: const TextStyle(
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
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    _formatDuration(video.durationSec),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    _formatDate(video.sentDate),
                    style: const TextStyle(
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

  Widget _buildThumbnailWidget(String thumbnailPath) {
    return Container(
      width: 140,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[300],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image(
          image: _getThumbnailImage(thumbnailPath),
          width: 140,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // If image fails to load, show a placeholder
            return Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.videocam_outlined,
                color: Colors.grey,
                size: 40,
              ),
            );
          },
        ),
      ),
    );
  }

  ImageProvider _getThumbnailImage(String thumbnailPath) {
    if (thumbnailPath.startsWith('http')) {
      return NetworkImage(thumbnailPath);
    } else if (thumbnailPath.isNotEmpty) {
      return NetworkImage('http://localhost:3000$thumbnailPath');
    } else {
      // Use AssetImage for placeholder
      return const AssetImage('Asset/Thumbnail-Fake.png');
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