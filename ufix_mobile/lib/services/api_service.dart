// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      // untuk emulator Android 
      return 'http://10.0.2.2:3000/api/auth';
    } else {
      // jika jalan di web atau HP fisik
      return 'http://192.168.56.1:3000/api/auth'; // ganti IP sesuai IP yang dipakai
    }
  }

  static Future<Map<String, dynamic>> signUp(
      String email, String displayName, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/signUp'),
        headers: {'Content-Type': 'application/json'},
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
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
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
}
