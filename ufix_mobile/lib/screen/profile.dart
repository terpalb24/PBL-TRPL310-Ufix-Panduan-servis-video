import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A567A),
        title: const Text(
          'Profil',
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
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // FOTO PROFILE
            CircleAvatar(
              radius: 55,
              backgroundColor: const Color(0xFF3A567A),
              child: const CircleAvatar(
                radius: 52,
                backgroundImage: AssetImage('assets/images/profile.png'),
                // kalau belum ada image:
                // child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),

            const SizedBox(height: 16),

            // NAMA
            const Text(
              "Indria Ria",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: 'Kodchasan',
              ),
            ),

            const SizedBox(height: 4),

            // EMAIL
            Text(
              "indria@email.com",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontFamily: 'Kodchasan',
              ),
            ),

            const SizedBox(height: 32),

            // FIELD NAMA
            _buildProfileField(
              title: "Nama",
              value: "Indria Ria",
              icon: Icons.person,
            ),

            // FIELD EMAIL
            _buildProfileField(
              title: "Email",
              value: "indria@email.com",
              icon: Icons.email,
            ),

            const SizedBox(height: 40),

            // LOGOUT
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
            _bottomItem(Icons.person, "Profile", true, null),
          ],
        ),
      ),
    );
  }

  // PROFILE FIELD
  Widget _buildProfileField({
    required String title,
    required String value,
    required IconData icon,
  }) {
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
        children: [
          Icon(icon, color: const Color(0xFF3A567A)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontFamily: 'Kodchasan',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: 'Kodchasan',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BOTTOM NAV ITEM
  static Widget _bottomItem(
      IconData icon, String text, bool active, VoidCallback? onTap) {
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
