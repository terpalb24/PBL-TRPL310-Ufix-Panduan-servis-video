import 'package:flutter/material.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/models/user_model.dart';
import 'package:ufix_mobile/services/storage_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? _user;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await ApiService.getProfile();
      
      if (response['success'] == true) {
        // Parse the user data from the response
        final userData = response['user'];
        
        // Create User object from response
        // Note: Backend returns 'idPengguna' but User model expects 'id'
        final user = User(
          id: userData['idPengguna'],
          email: userData['email'],
          displayName: userData['displayName'],
          token: await StorageService.getToken(),
        );
        
        setState(() {
          _user = user;
          _isLoading = false;
        });
        
        // Optionally save user data to storage for offline access
        await StorageService.saveUserDisplayName(user.displayName);
        await StorageService.saveUserEmail(user.email);
        await StorageService.saveUserId(user.id.toString());
        
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Failed to load profile';
          _isLoading = false;
        });
        
        // If token is invalid/expired, navigate to login
        if (response['message']?.contains('Session expired') == true) {
          _showSessionExpiredDialog();
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: $e';
        _isLoading = false;
      });
    }
  }

  void _showSessionExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please login again.'),
        actions: [
          TextButton(
            onPressed: () async {
              await StorageService.clearToken();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService.clearToken();
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Color(0xFF3A567A)),
          SizedBox(height: 16),
          Text('Loading profile...', style: TextStyle(fontFamily: 'Kodchasan')),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Kodchasan', color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3A567A),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontFamily: 'Kodchasan'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _user == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'No user data available',
                            style: TextStyle(fontFamily: 'Kodchasan'),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadUserProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3A567A),
                            ),
                            child: const Text(
                              'Load Profile',
                              style: TextStyle(fontFamily: 'Kodchasan'),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          // FOTO PROFILE
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: const Color(0xFF3A567A),
                            child: CircleAvatar(
                              radius: 52,
                              backgroundImage:
                                  const AssetImage('assets/images/profile.png'),
                              // You can also use a network image if you have profile picture URL
                              // backgroundImage: _user!.profilePictureUrl != null 
                              //     ? NetworkImage(_user!.profilePictureUrl!) 
                              //     : null,
                              child: _user == null
                                  ? const Icon(Icons.person,
                                      size: 50, color: Colors.white)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // NAMA
                          Text(
                            _user!.displayName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Kodchasan',
                            ),
                          ),
                          const SizedBox(height: 4),
                          // EMAIL
                          Text(
                            _user!.email,
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
                            value: _user!.displayName,
                            icon: Icons.person,
                          ),
                          // FIELD EMAIL
                          _buildProfileField(
                            title: "Email",
                            value: _user!.email,
                            icon: Icons.email,
                          ),
                          const SizedBox(height: 40),
                          // LOGOUT
                          GestureDetector(
                            onTap: _handleLogout,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 20),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F7FA),
                                border: Border(
                                  top: BorderSide(color: Colors.grey.shade300),
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
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
  Widget _bottomItem(
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