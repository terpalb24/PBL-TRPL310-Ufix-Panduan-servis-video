import 'package:flutter/material.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/services/storage_service.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Bookmarks',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3A567A),
                      fontFamily: 'Kodchasan',
                    ),
                  ),
                  const Spacer(),
                  if (!_loading && _bookmarks.isNotEmpty)
                    IconButton(
                      onPressed: _loadBookmarks,
                      icon: const Icon(Icons.refresh),
                      color: const Color(0xFF3A567A),
                    ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search bookmarks...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),

            // Bookmark List
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF3A567A),
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error, size: 60, color: Colors.red),
                              const SizedBox(height: 16),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _loadBookmarks,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF3A567A),
                                ),
                                child: const Text(
                                  'Try Again',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      : _filteredBookmarks.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.bookmark_border,
                                    size: 80,
                                    color: Color(0xFF3A567A),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _bookmarks.isEmpty
                                        ? 'No bookmarks yet'
                                        : 'No matching bookmarks',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF3A567A),
                                    ),
                                  ),
                                  if (_bookmarks.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Navigate to homepage or search
                                          Navigator.pop(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF3A567A),
                                        ),
                                        child: const Text(
                                          'Explore Videos',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredBookmarks.length,
                              itemBuilder: (context, index) {
                                final bookmark = _filteredBookmarks[index];
                                return _BookmarkItem(
                                  bookmark: bookmark,
                                  onRemove: () => _removeBookmark(bookmark['idVideo']),
                                );
                              },
                            ),
            ),
          ],
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

  @override
  Widget build(BuildContext context) {
    final title = bookmark['title'] ?? 'No Title';
    final uploader = bookmark['uploaderName'] ?? 'Unknown';
    final date = bookmark['sentDate'] ?? '';
    final imageUrl = _getImageUrl(bookmark['thumbnailPath']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail with error handling
          Container(
            width: 120,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                width: 120,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.video_library,
                      color: Colors.grey,
                      size: 40,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By: $uploader',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Remove button
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.bookmark_remove, color: Colors.red),
          ),
        ],
      ),
    );
  }
}