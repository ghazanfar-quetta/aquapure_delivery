import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_rest_auth.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Make it a singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentUserId;
  Map<String, dynamic>? _currentUserData;

  // Sign up using REST API
  Future<Map<String, dynamic>?> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
    String address,
  ) async {
    try {
      print('🔄 Starting signup process for: $email');

      // Use REST API for authentication
      final authResult =
          await FirebaseRestAuth.signUpWithEmail(email, password);

      if (authResult != null && authResult['localId'] != null) {
        final userId = authResult['localId'];

        print('✅ Auth successful, saving user data to Firestore...');

        // Save user data to Firestore
        await _firestore.collection('users').doc(userId).set({
          'uid': userId,
          'email': email,
          'name': name,
          'phone': phone,
          'address': address,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Store current user session
        _currentUserId = userId;
        _currentUserData = {
          'uid': userId,
          'email': email,
          'name': name,
          'phone': phone,
          'address': address,
        };

        print('✅ User created and session stored for: $name');
        return _currentUserData;
      } else {
        print('❌ Auth result is null or missing localId');
        return null;
      }
    } catch (e) {
      print('🔥 Auth service error: $e');
      rethrow;
    }
  }

  // Real login with REST API
  Future<Map<String, dynamic>?> signInWithEmail(
      String email, String password) async {
    try {
      print('🔄 Starting login process for: $email');

      // First try REST API login
      final authResult =
          await FirebaseRestAuth.signInWithEmail(email, password);

      if (authResult != null && authResult['localId'] != null) {
        final userId = authResult['localId'];

        // Get user data from Firestore
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          // Store current user session
          _currentUserId = userId;
          _currentUserData = userData;

          print('✅ User signed in: ${userData['name']}');
          return userData;
        } else {
          print('❌ User document not found in Firestore');
          return null;
        }
      } else {
        print('❌ Auth result is null or missing localId');
        return null;
      }
    } catch (e) {
      print('🔥 Login error: $e');
      rethrow;
    }
  }

  // Get current user data
  Map<String, dynamic>? get currentUserData => _currentUserData;
  String? get currentUserId => _currentUserId;

  // Check if user is logged in
  bool get isLoggedIn => _currentUserId != null;

  // Sign out
  Future<void> signOut() async {
    _currentUserId = null;
    _currentUserData = null;
    print('✅ User signed out');
  }

  // Initialize user session on app start (call this in main.dart or splash screen)
  Future<void> initializeUserSession() async {
    // You can add logic here to check if user was previously logged in
    // For now, we'll rely on the manual login
  }
}
