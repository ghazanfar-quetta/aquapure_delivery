// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ⬅ REQUIRED for Firestore access
import 'firebase_rest_auth.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Make it a singleton
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentUserId;
  Map<String, dynamic>? _currentUserData;

  // ---------------------------------------------------------------------------
  // SIGNUP (REST + FirebaseAuth SDK FIX)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> signUpWithEmail(
    String email,
    String password,
    String name,
    String phone,
    String address,
  ) async {
    try {
      print('🔄 Starting signup process for: $email');

      // 1. REST Signup
      final authResult =
          await FirebaseRestAuth.signUpWithEmail(email, password);

      if (authResult != null && authResult['localId'] != null) {
        final userId = authResult['localId'];

        print('✅ REST Auth successful, User ID: $userId');

        // ---------------------------------------------------------------------
        // 2. CRITICAL FIX: Login using FirebaseAuth SDK so Firestore recognizes user
        // ---------------------------------------------------------------------
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          print('🔥 FirebaseAuth SDK login successful — Firestore will work.');
        } catch (sdkError) {
          print('❌ FirebaseAuth SDK login failed: $sdkError');
        }

        // 3. Prepare Firestore user data
        final userData = {
          'uid': userId,
          'email': email.trim(),
          'name': name.trim(),
          'phone': phone.trim(),
          'address': address.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        };

        // 4. Save to Firestore
        try {
          await _firestore.collection('users').doc(userId).set(userData);
          print('✅ Firestore profile created for UID: $userId');
        } catch (firestoreError) {
          print('❌ Firestore write error: $firestoreError');
          print(
              '⚠️ User exists in Auth but Firestore profile was NOT created.');
          rethrow;
        }

        _currentUserId = userId;
        _currentUserData = userData;

        return _currentUserData;
      } else {
        print('❌ REST Auth failed: No localId returned');
        return null;
      }
    } catch (e) {
      print('🔥 Signup Error: $e');

      if (e.toString().contains('permission-denied')) {
        print('🔐 Firestore permission-denied! Fix rules or token.');
      }

      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // LOGIN (REST + FirebaseAuth SDK FIX)
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> signInWithEmail(
      String email, String password) async {
    try {
      print('🔄 Starting login for: $email');

      // 1. REST Login
      final authResult =
          await FirebaseRestAuth.signInWithEmail(email, password);

      if (authResult != null && authResult['localId'] != null) {
        final userId = authResult['localId'];

        print('✅ REST Auth login: UID = $userId');

        // ---------------------------------------------------------------------
        // 2. CRITICAL FIX: Also login using FirebaseAuth SDK for Firestore
        // ---------------------------------------------------------------------
        try {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
          print('🔥 FirebaseAuth SDK login successful — Firestore unlocked.');
        } catch (sdkError) {
          print('❌ FirebaseAuth SDK login failed: $sdkError');
        }

        // 3. Load Firestore user
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;

          _currentUserId = userId;
          _currentUserData = userData;

          print('✅ User data loaded: ${userData['name']}');
          return userData;
        } else {
          print('⚠️ No Firestore profile found — creating new one...');

          final newData = {
            'uid': userId,
            'email': email.trim(),
            'name': 'User',
            'phone': '',
            'address': '',
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'isActive': true,
          };

          await _firestore.collection('users').doc(userId).set(newData);

          _currentUserId = userId;
          _currentUserData = newData;

          return newData;
        }
      } else {
        print('❌ REST Login failed: missing localId');
        return null;
      }
    } catch (e) {
      print('🔥 Login error: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // USER SESSION
  // ---------------------------------------------------------------------------
  Map<String, dynamic>? get currentUserData => _currentUserData;
  String? get currentUserId => _currentUserId;

  bool get isLoggedIn => _currentUserId != null;

  Future<void> signOut() async {
    _currentUserId = null;
    _currentUserData = null;
    await FirebaseAuth.instance.signOut();
    print('✅ User signed out');
  }

  // ---------------------------------------------------------------------------
  // USER HELPERS
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print('❌ Error while fetching user by ID: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Profile updated for: $userId');
    } catch (e) {
      print('❌ Profile update failed: $e');
      rethrow;
    }
  }

  Future<void> deleteUserAccount(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
      print('⚠️ Firestore user data deleted. Auth still exists.');

      _currentUserId = null;
      _currentUserData = null;

      print('✅ Local session cleared.');
    } catch (e) {
      print('❌ Account delete error: $e');
      rethrow;
    }
  }
}
