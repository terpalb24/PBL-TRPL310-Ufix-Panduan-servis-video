// lib/screens/searched.dart
import 'package:flutter/material.dart';
import 'package:ufix_mobile/services/api_service.dart';

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
  List<Map<String, dynamic>> _videos = [];

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
        _videos = List<Map<String, dynamic>>.from(result['videos'] as List);
      } else {
        _error = result['message']?.toString() ?? 'Gagal memuat hasil pencarian';
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        child: CircularProgressIndicator(
          color: Color(0xFF3A567A),
        ),
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
      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
          side: const BorderSide(
            width: 1,
            color: Color(0xFF3A567A),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check,
            size: 14,
            color: Color(0xFF3A567A),
          ),
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

  Widget _buildResultTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildVideoResultItem(Map<String, dynamic> video) {
    final title = (video['title'] ?? '') as String;
    final tagsField = video['tags'] ?? video['tag'] ?? '';
    final tags = tagsField
        .toString()
        .split(RegExp(r'[,\s]+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final sentDateText = (video['sentDate'] ?? '').toString();

    return Container(
      height: 180,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFF3A567A),
          ),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 130,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: const Color(0xFFE0E0E0),
              image: video['thumbnailPath'] != null &&
                      (video['thumbnailPath'] as String).isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(video['thumbnailPath'] as String),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: video['thumbnailPath'] == null ||
                    (video['thumbnailPath'] as String).isEmpty
                ? const Icon(Icons.play_circle_fill,
                    size: 48, color: Color(0xFF3A567A))
                : null,
          ),

          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontFamily: 'Kodchasan',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Date
                  Text(
                    sentDateText,
                    style: const TextStyle(
                      color: Color(0x803A567A),
                      fontSize: 10,
                      fontFamily: 'Jost',
                    ),
                  ),
                  const SizedBox(height: 8),

                  // tags
                  if (tags.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children:
                          tags.map((t) => _buildResultTag(t)).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
