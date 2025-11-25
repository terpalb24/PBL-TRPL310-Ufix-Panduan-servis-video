import 'package:flutter/material.dart';
import 'settings.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

      // App Bar
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A567A),
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            fontFamily: 'Kodchasan',
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Transform.rotate(
            angle: 3.14,
            child: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          ),
        ),
      ),

      // Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Videos"),
            _buildToggleSetting("Tunjukkan Video Sulit", "Lihat Video Yang Lebih Menantang", false),
            _buildToggleSetting("Aktifkan Video Rekomendasi", "Biarkan Kami Sarankan Video", true),

            _buildSectionHeader("Data Diri"),
            _buildTextSetting("Profilku", "Lakukan Perubahan Pada Profilmu"),
            _buildTextSetting("Atur Ulang Riwayat", "Perbarui Riwayat Tontonanmu"),
            _buildTextSetting("Hapus Bookmark", "Hapus Bookmark Yang Tidak Diperlukan Lagi"),

            // Logout
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FA),
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade300),
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      "Logout",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Kodchasan',
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                    Icon(Icons.logout, color: Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation
      bottomNavigationBar: Container(
        height: 75,
        color: const Color(0xFF3A567A),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(Icons.home, "Home", false, () {
              Navigator.pushNamed(context, '/home');
            }),
            _bottomItem(Icons.search, "Search", false, () {
              Navigator.pushNamed(context, '/search');
            }),
            _bottomItem(Icons.bookmark, "Bookmark", false, () {
              Navigator.pushNamed(context, '/bookmark');
            }),
            _bottomItem(Icons.settings, "Settings", true, null),
          ],
        ),
      ),
    );
  }

  // Section Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Kodchasan',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Toggle Setting Item
  Widget _buildToggleSetting(String title, String subtitle, bool value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Kodchasan',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: 'Kodchasan',
                  ),
                ),
              ],
            ),
          ),

          // Switch (fixed: no deprecated)
          Switch(
            value: value,
            onChanged: (_) {},
            activeThumbColor: const Color(0xFF3A567A),
            activeTrackColor: const Color(0xFF3A567A).withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }

  // Text Setting Item
  Widget _buildTextSetting(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: 'Kodchasan',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontFamily: 'Kodchasan',
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade500),
        ],
      ),
    );
  }

  // Bottom Navigation Item
  Widget _bottomItem(IconData icon, String text, bool active, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: active ? const Color(0xFFFF7F00) : const Color(0xFFF7F7FA),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: TextStyle(
              color: active ? const Color(0xFFFF7F00) : const Color(0xFFF7F7FA),
              fontSize: 11,
              fontFamily: 'Kodchasan',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}