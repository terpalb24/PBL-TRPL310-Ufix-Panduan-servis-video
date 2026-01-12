// lib/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userDisplayNameKey = 'user_display_name';
  
  // Save JWT token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  // Get JWT token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  // Save user ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }
  
  // Get user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }
  
  // Save user email
  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _userEmailKey, value: email);
  }
  
  // Get user email
  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _userEmailKey);
  }
  
  // Save display name
  static Future<void> saveUserDisplayName(String displayName) async {
    await _storage.write(key: _userDisplayNameKey, value: displayName);
  }
  
  // Get display name
  static Future<String?> getUserDisplayName() async {
    return await _storage.read(key: _userDisplayNameKey);
  }
  
  // Clear all auth data
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userEmailKey);
    await _storage.delete(key: _userDisplayNameKey);
  }
  
  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}