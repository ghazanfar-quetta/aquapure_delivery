// lib/services/firebase_rest_auth.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kDebugMode;

class FirebaseRestAuth {
  static String? _apiKey;

  static void initialize({required String apiKey}) {
    _apiKey = apiKey;
    if (kDebugMode) {
      print('🔑 FirebaseRestAuth initialized with API key: $apiKey');
    }
  }

  // For debugging checks without throwing immediately:
  static bool get isInitialized => _apiKey != null && _apiKey!.isNotEmpty;

  static String get apiKey {
    if (!isInitialized) {
      throw Exception(
        'Firebase API key not initialized. Call FirebaseRestAuth.initialize() in main.dart',
      );
    }
    return _apiKey!;
  }

  static const String baseUrl = 'https://identitytoolkit.googleapis.com/v1';
  static const String signUpUrl = '$baseUrl/accounts:signUp';
  static const String signInUrl = '$baseUrl/accounts:signInWithPassword';

  // ---------------- SIGN UP ---------------- //
  static Future<Map<String, dynamic>?> signUpWithEmail(
    String email,
    String password,
  ) async {
    try {
      print('🔄 REST: Attempting signup for: $email');

      final response = await http.post(
        Uri.parse('$signUpUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password.trim(),
          'returnSecureToken': true,
        }),
      );

      print('📡 REST Signup response: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        print('✅ REST Signup successful!');
        return data;
      }

      throw _translateFirebaseError(
        data['error']?['message'] ?? 'Unknown error',
      );
    } catch (e) {
      print('🔥 REST Signup error: $e');
      rethrow;
    }
  }

  // ---------------- SIGN IN ---------------- //
  static Future<Map<String, dynamic>?> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      print('🔄 REST: Attempting login for: $email');

      final response = await http.post(
        Uri.parse('$signInUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email.trim(),
          'password': password.trim(),
          'returnSecureToken': true,
        }),
      );

      print('📡 REST Login response: ${response.statusCode}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        print('✅ REST Login successful!');
        return data;
      }

      throw _translateFirebaseError(
        data['error']?['message'] ?? 'Unknown error',
      );
    } catch (e) {
      print('🔥 REST Login error: $e');
      rethrow;
    }
  }

  static String _translateFirebaseError(String message) {
    if (message.contains('EMAIL_EXISTS')) {
      return 'This email is already registered.';
    }
    if (message.contains('INVALID_EMAIL')) {
      return 'Invalid email address.';
    }
    if (message.contains('WEAK_PASSWORD')) {
      return 'Password must be at least 6 characters.';
    }
    if (message.contains('EMAIL_NOT_FOUND')) {
      return 'No account found with this email.';
    }
    if (message.contains('INVALID_PASSWORD')) {
      return 'Incorrect password.';
    }
    if (message.contains('USER_DISABLED')) {
      return 'This account has been disabled.';
    }
    if (message.contains('TOO_MANY_ATTEMPTS_TRY_LATER')) {
      return 'Too many attempts. Try again later.';
    }
    return message;
  }
}
