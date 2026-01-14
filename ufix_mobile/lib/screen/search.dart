// lib/screen/search.dart
import 'package:flutter/material.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/models/tag_model.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Tag> _allTags = [];
  bool _isLoadingTags = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAllTags();
  }

  Future<void> _loadAllTags() async {
    setState(() {
      _isLoadingTags = true;
      _errorMessage = '';
    });

    try {
      final result = await ApiService.getAllTags();
      
      if (result['success'] == true) {
        setState(() {
          _allTags = result['tags'] as List<Tag>;
          _isLoadingTags = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load tags';
          _isLoadingTags = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoadingTags = false;
      });
    }
  }

  void _openResult(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan minimal satu kata kunci / tag')),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      '/searched_videos',
      arguments: {'query': query},
    );
  }

  void _addTagToSearch(String tag) {
    final currentText = _searchController.text.trim();
    
    if (currentText.isEmpty) {
      _searchController.text = tag;
    } else {
      _searchController.text = '$currentText $tag';
    }
    
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: _searchController.text.length),
    );
    
    _searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                
                // Header
                Container(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cari Tutorial',
                        style: TextStyle(
                          color: Color(0xFF3A567A),
                          fontSize: 24,
                          fontFamily: 'Kodchasan',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Masukkan nama alat / topik yang ingin kamu perbaiki.',
                        style: TextStyle(
                          color: Color(0xFF3A567A),
                          fontSize: 14,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search box
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  width: 1,
                                  color: const Color(0xFF3A567A),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  onSubmitted: _openResult,
                                  style: const TextStyle(
                                    fontFamily: 'Jost',
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Contoh: TV tidak menyala',
                                    hintStyle: TextStyle(
                                      color: Color(0x803A567A),
                                      fontSize: 14,
                                      fontFamily: 'Jost',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3A567A),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF3A567A).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => _openResult(_searchController.text),
                              icon: const Icon(
                                Icons.search,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recommended tags section
                _buildSection(
                  title: 'Rekomendasi Tag',
                  content: _buildRecommendedTags(),
                ),

                const SizedBox(height: 16),

                // Popular categories section
                _buildSection(
                  title: 'Kategori Populer',
                  content: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildCategoryChip('Gadget', Icons.phone_android),
                      _buildCategoryChip('Elektronik Rumah', Icons.tv),
                      _buildCategoryChip('Komputer & Laptop', Icons.computer),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // All Tags from Database section
                _buildAllTagsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF3A567A),
              fontSize: 18,
              fontFamily: 'Kodchasan',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3A567A), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: () => _addTagToSearch(title),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        icon: Icon(
          icon,
          size: 20,
          color: const Color(0xFF3A567A),
        ),
        label: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF3A567A),
            fontSize: 14,
            fontFamily: 'Jost',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAllTagsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Semua Tag (${_allTags.length})',
                style: const TextStyle(
                  color: Color(0xFF3A567A),
                  fontSize: 18,
                  fontFamily: 'Kodchasan',
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A567A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.refresh,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                onPressed: _isLoadingTags ? null : _loadAllTags,
                splashRadius: 20,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAllTagsContent(),
        ],
      ),
    );
  }

  Widget _buildAllTagsContent() {
    if (_isLoadingTags) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              CircularProgressIndicator(
                color: const Color(0xFF3A567A),
                strokeWidth: 2,
              ),
              const SizedBox(height: 12),
              Text(
                'Memuat tag...',
                style: TextStyle(
                  color: const Color(0xFF3A567A).withOpacity(0.7),
                  fontSize: 14,
                  fontFamily: 'Jost',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: Column(
          children: [
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontFamily: 'Jost',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadAllTags,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A567A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Jost',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_allTags.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.tag,
                size: 60,
                color: const Color(0xFF3A567A).withOpacity(0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak ada tag tersedia',
                style: TextStyle(
                  color: const Color(0xFF3A567A).withOpacity(0.7),
                  fontSize: 16,
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _allTags
          .map(
            (tag) => _buildTagButton(tag.tag),
          )
          .toList(),
    );
  }

  Widget _buildRecommendedTags() {
    final tags = [
      'Samsung',
      'Laptop',
      'Iphone',
      'LG',
      'Mesin cuci',
      'AC',
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: tags
          .map(
            (t) => _buildTagButton(t),
          )
          .toList(),
    );
  }

  Widget _buildTagButton(String text) {
    return ElevatedButton(
      onPressed: () => _addTagToSearch(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF3A567A),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
          side: const BorderSide(
            color: Color(0xFF3A567A),
            width: 1,
          ),
        ),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}