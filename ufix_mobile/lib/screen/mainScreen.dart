import 'package:flutter/material.dart';
import 'package:ufix_mobile/services/api_service.dart';
import 'package:ufix_mobile/services/storage_service.dart';
import 'homepage.dart';
import 'search.dart';
import 'bookmark.dart';

class FrontScreen extends StatefulWidget {
  const FrontScreen({super.key});

  @override
  State<FrontScreen> createState() => _FrontScreenState();
}

class _FrontScreenState extends State<FrontScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _userDisplayName;
  String? _userRole;

  final List<Widget> _pages = [
    Homepage(),
    Search(),
    Bookmark(),
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      // Check if token exists in storage
      final token = await StorageService.getToken();
      
      if (token == null || token.isEmpty) {
        // No token found, redirect to login
        _redirectToLogin();
        return;
      }

      // Use ApiService.getProfile() which already handles the API call
      final profileResult = await ApiService.getProfile();
      
      if (profileResult['success'] == true) {
        final user = profileResult['user'];
        setState(() {
          _isAuthenticated = true;
          _userDisplayName = user['displayName'];
          _userRole = user['role'];
          _isLoading = false;
        });
      } else {
        // Token is invalid or expired
        await StorageService.clearToken();
        _redirectToLogin();
      }
    } catch (error) {
      print('Auth check error: $error');
      await StorageService.clearToken();
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  void _onItemTapped(int index) {
    if (!_isAuthenticated) {
      _redirectToLogin();
      return;
    }
    
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use ApiService.logout() to properly logout from backend too
      await ApiService.logout();
      
      // Clear local storage and redirect
      await StorageService.clearToken();
      _redirectToLogin();
    } catch (error) {
      print('Logout error: $error');
      // Even if API fails, clear local storage
      await StorageService.clearToken();
      _redirectToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Color(0xFF3A567A),
              ),
              SizedBox(height: 20),
              Text(
                'Checking authentication...',
                style: TextStyle(
                  color: Color(0xFF3A567A),
                  fontFamily: 'Jost',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              SizedBox(height: 20),
              Text(
                'Authentication required',
                style: TextStyle(
                  color: Color(0xFF3A567A),
                  fontSize: 18,
                  fontFamily: 'Kodchasan',
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _redirectToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3A567A),
                ),
                child: Text(
                  'Go to Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Jost',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          'U-Fix',
          style: TextStyle(
            fontFamily: 'Kodchasan',
            fontWeight: FontWeight.w600,
            color: Color(0xFF3A567A),
          ),
        ),
        backgroundColor: Color(0xFFF7F7FA),
        elevation: 0,
        actions: [
          if (_userDisplayName != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: Color(0xFF3A567A),
                  ),
                  SizedBox(width: 8),
                  Text(
                    _userDisplayName!,
                    style: TextStyle(
                      color: Color(0xFF3A567A),
                      fontFamily: 'Jost',
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: Icon(Icons.logout),
            color: Color(0xFF3A567A),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFFF7F7FA),
        selectedItemColor: Color(0XFFFF7F00),
        unselectedItemColor: Color(0xFF3A567A),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            activeIcon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
        ],
      ),
    );
  }
}