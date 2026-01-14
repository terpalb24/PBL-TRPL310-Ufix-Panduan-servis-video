import 'package:flutter/material.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/services/storage_service.dart';
import 'package:ufix_mobile/models/video_model.dart';
import 'package:ufix_mobile/screen/fakeplayer.dart';

class Bookmark extends StatefulWidget {
  const Bookmark({super.key});

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _bookmarks = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final result = await ApiService.getBookmarks();

    if (!mounted) return;

    if (result['success'] == true) {
      final data = result['data'];
      final bookmarks = (data['bookmarks'] ?? []) as List;
      setState(() {
        _bookmarks = bookmarks.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } else {
      if (result['needsLogin'] == true) {
        await StorageService.clearToken();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }
      setState(() {
        _loading = false;
        _error = result['message'] ?? 'Failed to load bookmarks';
      });
    }
  }

  Future<void> _removeBookmark(int videoId) async {
    final result = await ApiService.removeBookmark(videoId);
  
    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _bookmarks.removeWhere((b) => b['idVideo'] == videoId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Removed'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (result['needsLogin'] == true) {
        await StorageService.clearToken();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToVideoPlayerFromBookmark(Map<String, dynamic> bookmark) {
    final video = Video(
      idVideo: bookmark['idVideo'] ?? 0,
      title: bookmark['title'] ?? 'No Title',
      videoPath: bookmark['videoPath'] ?? '',
      thumbnailPath: bookmark['thumbnailPath'] ?? '',
      mimeType: bookmark['mimeType'] ?? "",
      deskripsi: bookmark['deskripsi'] ?? "",
      sentDate: bookmark['sentDate'] != null 
          ? DateTime.tryParse(bookmark['sentDate'].toString()) 
          : null,
    );
    
    Navigator.pushNamed(
      context, '/player', arguments: video
    );
  }

  List<Map<String, dynamic>> get _filteredBookmarks {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _bookmarks;
    return _bookmarks.where((b) {
      final title = (b['title'] ?? '').toString().toLowerCase();
      final uploader = (b['uploaderName'] ?? '').toString().toLowerCase();
      return title.contains(query) || uploader.contains(query);
    }).toList();
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
          child: Column(
            children: [
              // Header with back button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF3A567A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Bookmarks',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A567A),
                        fontFamily: 'Kodchasan',
                      ),
                    ),
                    const Spacer(),
                    if (!_loading && _bookmarks.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A567A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _loadBookmarks,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Stats banner
              if (_bookmarks.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF3A567A), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Bookmark',
                            style: TextStyle(
                              color: Color(0xFF3A567A),
                              fontSize: 14,
                              fontFamily: 'Jost',
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Text(
                            '${_bookmarks.length} video${_bookmarks.length != 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Color(0xFF3A567A),
                              fontSize: 24,
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
                          'Semua',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Jost',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF3A567A), width: 1),
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
                      const Icon(
                        Icons.search,
                        color: Color(0xFF3A567A),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search bookmarks...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Color(0x803A567A),
                              fontSize: 14,
                              fontFamily: 'Jost',
                            ),
                          ),
                          onChanged: (value) => setState(() {}),
                          style: const TextStyle(
                            color: Color(0xFF3A567A),
                            fontSize: 14,
                            fontFamily: 'Jost',
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFF3A567A),
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bookmark List
              Expanded(
                child: _loading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: const Color(0xFF3A567A),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Loading bookmarks...',
                              style: TextStyle(
                                color: Color(0xFF3A567A),
                                fontSize: 16,
                                fontFamily: 'Jost',
                              ),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              margin: const EdgeInsets.symmetric(horizontal: 24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 60,
                                    color: Colors.red,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF3A567A),
                                      fontFamily: 'Jost',
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _loadBookmarks,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3A567A),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Try Again',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Jost',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _filteredBookmarks.isEmpty
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  margin: const EdgeInsets.symmetric(horizontal: 24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(20),
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
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _bookmarks.isEmpty
                                            ? Icons.bookmark_border
                                            : Icons.search_off,
                                        size: 80,
                                        color: const Color(0xFF3A567A).withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _bookmarks.isEmpty
                                            ? 'No bookmarks yet'
                                            : 'No matching bookmarks',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Color(0xFF3A567A),
                                          fontFamily: 'Kodchasan',
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _bookmarks.isEmpty
                                            ? 'Tap the bookmark icon on videos to save them here'
                                            : 'Try a different search term',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                          fontFamily: 'Jost',
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      if (_bookmarks.isEmpty)
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF3A567A),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 32, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                          ),
                                          child: const Text(
                                            'Explore Videos',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Jost',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadBookmarks,
                                color: const Color(0xFF3A567A),
                                backgroundColor: Colors.white.withOpacity(0.7),
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _filteredBookmarks.length,
                                  itemBuilder: (context, index) {
                                    final bookmark = _filteredBookmarks[index];
                                    return GestureDetector(
                                      onTap: () {
                                        _navigateToVideoPlayerFromBookmark(bookmark);
                                      },
                                      child: _BookmarkItem(
                                        bookmark: bookmark,
                                        onRemove: () => _removeBookmark(bookmark['idVideo']),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookmarkItem extends StatelessWidget {
  final Map<String, dynamic> bookmark;
  final VoidCallback onRemove;

  const _BookmarkItem({
    required this.bookmark,
    required this.onRemove,
  });

  String _getImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'http://localhost:3000/placeholder.jpg';
    }
    return path.startsWith('http') ? path : 'http://localhost:3000$path';
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.tryParse(dateString);
      if (date == null) return dateString;
      
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
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = bookmark['title'] ?? 'No Title';
    final uploader = bookmark['uploaderName'] ?? 'Unknown';
    final date = _formatDate(bookmark['sentDate']?.toString());
    final imageUrl = _getImageUrl(bookmark['thumbnailPath']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 1, color: const Color(0xFF3A567A).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 120,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              color: Colors.grey[300],
              border: Border.all(color: const Color(0xFF3A567A).withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Image.network(
                imageUrl,
                width: 120,
                height: 100,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFF3A567A),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
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
                          Icons.video_library,
                          color: Colors.grey,
                          size: 40,
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
              ),
            ),
          ),

          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Jost',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          uploader,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'Jost',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontFamily: 'Jost',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
              ),
              child: const Icon(
                Icons.bookmark_remove,
                color: Colors.red,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}