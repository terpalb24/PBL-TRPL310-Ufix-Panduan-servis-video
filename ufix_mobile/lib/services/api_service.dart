// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:ufix_mobile/services/storage_service.dart';

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  static Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // Get token from storage
    final token = await StorageService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ================================
  //            AUTH
  // ================================
  static Future<Map<String, dynamic>> signUp(
    String email,
    String displayName,
    String PASSWORD,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signUp'),
        headers: {'Content-Type': 'application/json'},
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
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Save token if login successful
        if (data['success'] == true && data['token'] != null) {
          await StorageService.saveToken(data['token']);

          // Save user info if available
          if (data['user'] != null) {
            await StorageService.saveUserId(data['user']['id'].toString());
          }
        }

        return data;
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Get user profile with authentication
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/auth/profile'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await StorageService.clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get profile: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Validate token
  static Future<bool> validateToken() async {
    final profileResult = await getProfile();
    return profileResult['success'] == true;
  }

  // Logout
  static Future<void> logout() async {
    try {
      final headers = await getHeaders();

      // Call logout endpoint if exists
      await http.post(Uri.parse('$baseUrl/auth/logout'), headers: headers);
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      await StorageService.clearToken();
    }
  }

  // ================================
  //            BOOKMARKS
  // ================================
  static Future<Map<String, dynamic>> getBookmarks() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/bookmark/get'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        await StorageService.clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'needsLogin': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get bookmarks: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> addBookmark(int videoId) async {
    try {
      final headers = await getHeaders();

      final response = await http.post(
        Uri.parse('$baseUrl/bookmark/$videoId'),
        headers: headers,
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Bookmark added successfully'};
      } else if (response.statusCode == 200) {
        // Already bookmarked (your backend returns 200 for this)
        return {'success': true, 'message': 'Already bookmarked'};
      } else if (response.statusCode == 401) {
        await StorageService.clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'needsLogin': true,
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Video not found'};
      } else {
        return {
          'success': false,
          'message': 'Failed to add bookmark: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> removeBookmark(int videoId) async {
    try {
      final headers = await getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/bookmark/$videoId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Bookmark removed successfully'};
      } else if (response.statusCode == 404) {
        return {'success': true, 'message': 'Bookmark not found'};
      } else if (response.statusCode == 401) {
        await StorageService.clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'needsLogin': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to remove bookmark: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<bool> isBookmarked(int videoId) async {
    try {
      final result = await getBookmarks();

      if (result['success'] == true) {
        final data = result['data'];
        final bookmarks = (data['bookmarks'] ?? []) as List;
        return bookmarks.any((b) => b['idVideo'] == videoId);
      }
      return false;
    } catch (e) {
      print('Error checking bookmark: $e');
      return false;
    }
  }

  // ================================
  //            SEARCH
  // ================================
  static Future<Map<String, dynamic>> searchVideos(String tag) async {
    try {
      final headers = await getHeaders();
      final uri = Uri.parse(
        '$baseUrl/search',
      ).replace(queryParameters: {'tag': tag});

      final response = await http.post(uri, headers: headers);

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ================================
  //     HOME – NEWEST VIDEOS
  // ================================
  static Future<Map<String, dynamic>> getNewVideos() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/video/new'),
        headers: headers,
      );

      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getVideoStreamUrl(int videoId) async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/video/url/$videoId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await StorageService.clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'needsLogin': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get video URL: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getHistory() async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await StorageService.clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'needsLogin': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get history: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Clear user's watch history
  static Future<Map<String, dynamic>> clearHistory() async {
    try {
      final headers = await getHeaders();

      final response = await http.delete(
        Uri.parse('$baseUrl/history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await StorageService.clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'needsLogin': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to clear history: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // In ApiService.dart, add this method:
  static Future<Map<String, dynamic>> getVideoDescription(int videoId) async {
    try {
      final headers = await getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl/video/deskripsi/$videoId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        await StorageService.clearToken();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
          'needsLogin': true,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get video deskripsi: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
