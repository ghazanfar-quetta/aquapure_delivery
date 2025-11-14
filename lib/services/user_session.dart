import 'package:cloud_firestore/cloud_firestore.dart';

class UserSession {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;

  // Set current user
  void setCurrentUser(String userId) {
    _currentUserId = userId;
  }

  // Get current user ID
  String? get currentUserId => _currentUserId;

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      if (_currentUserId != null) {
        await _firestore
            .collection('users')
            .doc(_currentUserId!)
            .update(updates);
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating profile: $e');
      return false;
    }
  }
}
