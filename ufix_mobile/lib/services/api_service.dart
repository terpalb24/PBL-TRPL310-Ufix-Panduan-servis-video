// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.1.11:3000/api'; // Remove /auth
    } else {
      return 'http://localhost:3000/api'; // Remove /auth
    }
  }

  // Add the missing getHeaders method
  static Map<String, String> getHeaders(String? token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> signUp(
      String email, String displayName, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signUp'), // Add /auth back here
        headers: getHeaders(null),
        body: json.encode({
          'email': email,
          'displayName': displayName,
          'password': password,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'), // Add /auth back here
        headers: getHeaders(null),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getNewVideos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/video/new'), // This is correct now
        headers: getHeaders(null),
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // In lib/services/api_service.dart
static Future<Map<String, dynamic>> getVideoUrl(int videoId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/video/url/$videoId'), // Adjust endpoint path as needed
      headers: getHeaders(null),
    );
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {
        'success': false, 
        'message': 'Server error: ${response.statusCode}'
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}
}