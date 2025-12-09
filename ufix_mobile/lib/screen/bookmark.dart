import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Service kecil untuk panggil backend bookmark (tanpa token).
class BookmarkApi {
  static const String _baseUrl = 'http://localhost:3000/api/bookmark';

  /// GET /api/bookmark
  static Future<List<Map<String, dynamic>>> fetchBookmarks() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: const {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil bookmark (${response.statusCode})');
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Format respons tidak sesuai');
    }

    // Sesuaikan dengan struktur JSON dari backend-mu
    final list = (decoded['bookmark'] ?? []) as List<dynamic>;
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// POST /api/bookmark/:id
  static Future<void> addBookmark(int videoId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/$videoId'),
      headers: const {
        'Content-Type': 'application/json',
      },
    );

    // Asumsi: 201 = berhasil, 409 = sudah ada bookmark (tidak fatal)
    if (response.statusCode != 201 && response.statusCode != 409) {
      throw Exception('Gagal menambah bookmark (${response.statusCode})');
    }
  }

  /// DELETE /api/bookmark/:id
  static Future<void> removeBookmark(int videoId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/$videoId'),
      headers: const {
        'Content-Type': 'application/json',
      },
    );

    // 200 = ok, 404 = sudah tidak ada
    if (response.statusCode != 200 && response.statusCode != 404) {
      throw Exception('Gagal menghapus bookmark (${response.statusCode})');
    }
  }

  /// Cek apakah video ini sudah di-bookmark
  static Future<bool> isBookmarked(int videoId) async {
    try {
      final list = await fetchBookmarks();
      return list.any((e) => e['idVideo'] == videoId);
    } catch (e) {
      debugPrint('Error isBookmarked: $e');
      return false;
    }
  }
}

class Bookmark extends StatefulWidget {
  const Bookmark({super.key});

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final data = await BookmarkApi.fetchBookmarks();
      if (!mounted) return;
      setState(() {
        _bookmarks = data;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
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
            decoration: const BoxDecoration(color: Color(0xFFF7F7FA)),
          ),

          // Header title
          const Positioned(
            left: 13,
            top: 20,
            child: Text(
              'Bookmark',
              style: TextStyle(
                color: Color(0xFF3A567A),
                fontSize: 40,
                fontFamily: 'Kodchasan',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Filter section (UI kamu yang lama)
          Positioned(
            left: 0,
            top: 75,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 197,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 20),
              decoration: ShapeDecoration(
                color: const Color(0xFFF7F7FA),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFF3A567A),
                  ),
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search bar
                  Container(
                    width: 239,
                    height: 40,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF0F7FC),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 1,
                          color: Color(0x193A567A),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari Video bookmark...',
                              hintStyle: TextStyle(
                                color: Colors.black.withOpacity(0.40),
                                fontSize: 14,
                                fontFamily: 'Jost',
                                fontWeight: FontWeight.w600,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildFilterButton('Tampilkan Uploader'),
                      const SizedBox(width: 10),
                      _buildFilterButton('Tampilkan Dikomentari'),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _buildFilterButton('Tampilkan Jumlah'),
                      const SizedBox(width: 10),
                      _buildFilterButton('Saring Berdasarkan'),
                    ],
                  ),
                  const SizedBox(height: 10),

                  _buildFilterButton('Urutkan dari'),
                ],
              ),
            ),
          ),

          // List bookmark
          Positioned(
            left: 0,
            top: 295,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 395,
              padding: const EdgeInsets.all(16),
              child: _buildBookmarkBody(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_bookmarks.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada bookmark.',
          style: TextStyle(
            color: Colors.black54,
            fontSize: 16,
            fontFamily: 'Jost',
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          for (final video in _bookmarks) ...[
            _buildBookmarkedVideoItem(context, video),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 30,
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
                'Lebih Banyak',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: ShapeDecoration(
        color: const Color(0xFFF0F7FC),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0x663A567A),
          ),
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontFamily: 'Jost',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 20,
            height: 20,
            decoration: ShapeDecoration(
              color: const Color(0x4C3A567A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkedVideoItem(
    BuildContext context,
    Map<String, dynamic> video,
  ) {
    final String title = (video['title'] ?? 'Tanpa Judul').toString();
    final String sentDate = (video['sentDate'] ?? '').toString();
    final String? thumbnailPath =
        video['thumbnailPath'] != null ? video['thumbnailPath'].toString() : null;

    final ImageProvider imageProvider =
        (thumbnailPath != null && thumbnailPath.isNotEmpty)
            ? NetworkImage('http://localhost:3000$thumbnailPath')
            : const AssetImage('Asset/Thumbnail-Fake.png');

    return Container(
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
          Container(
            width: 140,
            height: 80,
            decoration: ShapeDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Text(
                  'Uploader',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontFamily: 'Jost',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  sentDate.isEmpty ? 'Date/Month/Year' : sentDate,
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
    );
  }
}
