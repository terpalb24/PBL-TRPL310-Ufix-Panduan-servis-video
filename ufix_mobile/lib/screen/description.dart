// lib/screens/video_description_screen.dart
import 'package:flutter/material.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/services/storage_service.dart';

class VideoDescriptionScreen extends StatefulWidget {
  final int videoId;
  final String videoTitle;

  const VideoDescriptionScreen({
    super.key,
    required this.videoId,
    required this.videoTitle,
  });

  @override
  State<VideoDescriptionScreen> createState() => _VideoDescriptionScreenState();
}

class _VideoDescriptionScreenState extends State<VideoDescriptionScreen> {
  String _description = '';
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadVideoDescription();
  }

  Future<void> _loadVideoDescription() async {
    try {
      // Call the new API endpoint
      final result = await ApiService.getVideoDescription(widget.videoId);
      
      if (result['success'] == true) {
        final videoData = result['video'];
        setState(() {
          _description = videoData['description'] ?? 'No description available';
          _isLoading = false;
        });
      } else {
        if (result['needsLogin'] == true) {
          await _handleLogout();
          return;
        }
        
        setState(() {
          _hasError = true;
          _errorMessage = result['message'] ?? 'Failed to load description';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await StorageService.clearToken();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A567A),
        foregroundColor: Colors.white,
        title: Text(
          widget.videoTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF3A567A),
            ),
            SizedBox(height: 16),
            Text(
              'Loading description...',
              style: TextStyle(
                color: Color(0xFF3A567A),
                fontFamily: 'Jost',
              ),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(
                color: Color(0xFF3A567A),
                fontSize: 16,
                fontFamily: 'Jost',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadVideoDescription,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A567A),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Jost',
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF7FC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3A567A).withOpacity(0.2),
              ),
            ),
            child: Text(
              widget.videoTitle,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3A567A),
                fontFamily: 'Kodchasan',
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Description header
          const Row(
            children: [
              Icon(
                Icons.description,
                color: Color(0xFF3A567A),
              ),
              SizedBox(width: 8),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3A567A),
                  fontFamily: 'Kodchasan',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Description content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3A567A).withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              _description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
                fontFamily: 'Jost',
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Video info card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3A567A).withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Video Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3A567A),
                    fontFamily: 'Kodchasan',
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Video ID:', widget.videoId.toString()),
                _buildInfoRow('Characters:', _description.length.toString()),
                _buildInfoRow('Words:', _description.split(' ').length.toString()),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Copy description to clipboard
                  // You'll need to add the clipboard package: flutter pub add clipboard
                  // Or use: Clipboard.setData(ClipboardData(text: _description));
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Description'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A567A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () {
                  // Share the description
                  // You'll need to add the share package: flutter pub add share
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3A567A),
                  side: const BorderSide(color: Color(0xFF3A567A)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontFamily: 'Jost',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF3A567A),
                fontWeight: FontWeight.w500,
                fontFamily: 'Jost',
              ),
            ),
          ),
        ],
      ));
    }
  }