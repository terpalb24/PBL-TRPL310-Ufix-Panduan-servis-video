// lib/screens/settings.dart
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: const Color(0xFFFFF7F7),
          ),
          
          // Header
          Container(
            width: MediaQuery.of(context).size.width,
            height: 70,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 19),
            decoration: BoxDecoration(color: const Color(0xFF3A567A)),
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    transform: Matrix4.identity()..rotateZ(3.14),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFFF7F7FA),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 29),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: const Color(0xFFF7F7FA),
                    fontSize: 24,
                    fontFamily: 'Kodchasan',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          
          // Settings content
          Positioned(
            top: 70,
            left: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 145,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video Settings Section
                    _buildSectionHeader('Videos'),
                    _buildToggleSetting(
                      'Tunjukkan Video Sulit',
                      'Show difficult videos',
                      false,
                    ),
                    _buildToggleSetting(
                      'Aktifkan Video Rekomendasi',
                      'Enable video recommendations',
                      true,
                    ),
                    
                    // Personal Data Section
                    _buildSectionHeader('Data Diri'),
                    _buildTextSetting('Profilku', 'My Profile'),
                    _buildTextSetting('Reset History', 'Reset viewing history'),
                    _buildTextSetting('Clear Bookmark', 'Clear all bookmarks'),
                    
                    // Data Deletion Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Ajukan Penghapusan Data',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Kodchasan',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper method for section headers
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.black,
          fontSize: 15,
          fontFamily: 'Kodchasan',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  // Helper method for toggle settings
  Widget _buildToggleSetting(String title, String subtitle, bool value) {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 23),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        border: Border.all(width: 1, color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Kodchasan',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontFamily: 'Kodchasan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Switch(
            value: value,
            onChanged: (bool newValue) {
              // Handle toggle change
            },
            activeThumbColor: const Color(0xFF3A567A),
          ),
        ],
      ),
    );
  }
  
  // Helper method for text settings
  Widget _buildTextSetting(String title, String subtitle) {
    return Container(
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 33),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        border: Border.all(width: 1, color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Kodchasan',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontFamily: 'Kodchasan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey[500],
            size: 16,
          ),
        ],
      ),
    );
  }
}