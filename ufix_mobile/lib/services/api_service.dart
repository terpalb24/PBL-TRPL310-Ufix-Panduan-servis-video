// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {

      return 'http://10.0.2.2:3000/api'; // Remove /auth
    } else {
      return 'http://localhost:3000/api';
    }
  }

  static Map<String, String> getHeaders(String? token) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ================================
  //            AUTH
  // ================================
  static Future<Map<String, dynamic>> signUp(
      String email, String displayName, String PASSWORD) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signUp'),
        headers: getHeaders(null),
        body: json.encode({
          'email': email,
          'displayName': displayName,
          'PASSWORD': PASSWORD,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: getHeaders(null),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }


  //            SEARCH

  static Future<Map<String, dynamic>> searchVideos(String tag) async {
    try {
      final uri = Uri.parse('$baseUrl/search').replace(
        queryParameters: {'tag': tag},
      );

      final response = await http.post(
        uri,
        headers: getHeaders(null),
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  //     HOME – NEWEST VIDEOS

  static Future<Map<String, dynamic>> getNewVideos() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/video/new'),
        headers: getHeaders(null),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}
