// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:3000/api/auth';
  
  static Future<Map<String, dynamic>> signUp(String email, String displayName, String password) async {
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
    
    return json.decode(response.body);
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
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  
  static Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      return json.decode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}