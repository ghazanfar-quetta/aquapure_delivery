import 'dart:convert';
import 'package:http/http.dart' as http;

class FirebaseRestAuth {
  // You need to replace this with your actual Firebase Web API Key
  // Get it from: Firebase Console → Project Settings → General → Web API Key
  static const String apiKey = 'AIzaSyCJmZu01qxjMggRjHdsSVNSpdvHZN7D6Fs';

  static const String baseUrl = 'https://identitytoolkit.googleapis.com/v1';
  static const String signUpUrl = '$baseUrl/accounts:signUp';
  static const String signInUrl = '$baseUrl/accounts:signInWithPassword';

  // Sign up using REST API
  static Future<Map<String, dynamic>?> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      print('🔄 Attempting signup for: $email');

      final response = await http.post(
        Uri.parse('$signUpUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ REST Signup successful for: ${data['email']}');
        print('✅ User ID: ${data['localId']}');
        return data;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']['message'] ?? 'Unknown error';
        print('🔥 REST Signup failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('🔥 REST Signup error: $e');
      rethrow;
    }
  }

  // Sign in using REST API
  static Future<Map<String, dynamic>?> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      print('🔄 Attempting login for: $email');

      final response = await http.post(
        Uri.parse('$signInUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      print('📡 Login response status: ${response.statusCode}');
      print('📡 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ REST Login successful for: ${data['email']}');
        return data;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']['message'] ?? 'Unknown error';
        print('🔥 REST Login failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('🔥 REST Login error: $e');
      rethrow;
    }
  }
}
