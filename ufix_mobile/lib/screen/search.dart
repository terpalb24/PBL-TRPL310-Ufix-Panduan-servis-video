// lib/screen/search.dart
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            color: Colors.white,
          ),

          // Konten
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Cari Tutorial',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Kodchasan',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Masukkan nama alat / topik yang ingin kamu perbaiki.',
                    style: TextStyle(
                      color: Color(0xFF3A567A),
                      fontSize: 12,
                      fontFamily: 'Jost',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search box
                  _buildSection(
                    'Search',
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            child: Center(
                              child: TextField(
                                controller: _searchController,
                                onSubmitted: _openResult,
                                style: const TextStyle(
                                  fontFamily: 'Jost',
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Contoh: TV tidak menyala',
                                  hintStyle: TextStyle(
                                    color: Color(0x803A567A),
                                    fontSize: 12,
                                    fontFamily: 'Jost',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3A567A),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            onPressed: () => _openResult(_searchController.text),
                            child: const Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Recommended tags -> barang elektronik
                  _buildSection(
                    'Rekomendasi Tag',
                    _buildRecommendedTags(),
                  ),

                  const SizedBox(height: 16),

                  // Kategori populer -> elektronik juga
                  _buildSection(
                    'Kategori Populer',
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTagButton('Gadget'),
                        _buildTagButton('Elektronik Rumah'),
                        _buildTagButton('Komputer & Laptop'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSection(String title, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: const Color(0xFF3A567A),
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11,
              fontFamily: 'Kodchasan',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  // ==== Rekomendasi Tag: sekarang elektronik ====
  Widget _buildRecommendedTags() {
    final tags = [
      'TV',
      'Laptop',
      'HP',
      'Kulkas',
      'Mesin cuci',
      'AC',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags
          .map(
            (t) => GestureDetector(
              onTap: () => _openResult(t),
              child: _buildTagButton(t),
            ),
          )
          .toList(),
    );
  }

  // Tag pill
  Widget _buildTagButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontFamily: 'Jost',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}