import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Predefined admin credentials - change these to whatever you want
  static const String _predefinedUsername = 'aquapure';
  static const String _predefinedPassword = 'admin2024';
  static const String _adminCredentialsKey = 'admin_credentials_initialized';

  // Initialize admin credentials (run once)
  Future<void> _initializeAdminCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isInitialized = prefs.getBool(_adminCredentialsKey) ?? false;

      if (!isInitialized) {
        // Store that we've initialized the credentials
        await prefs.setBool(_adminCredentialsKey, true);
        print('✅ Predefined admin credentials set: $_predefinedUsername');
      }
    } catch (e) {
      print('❌ Error initializing admin credentials: $e');
    }
  }

  // Verify admin login
  Future<bool> verifyAdminLogin(String username, String password) async {
    try {
      // Ensure credentials are initialized
      await _initializeAdminCredentials();

      // Use predefined credentials
      final isValid =
          username == _predefinedUsername && password == _predefinedPassword;

      print('🔐 Login attempt: $username - Valid: $isValid');
      print(
          '💡 Predefined credentials: $_predefinedUsername / $_predefinedPassword');

      return isValid;
    } catch (e) {
      print('❌ Error verifying admin login: $e');

      // Fallback: check against predefined credentials even if SharedPreferences fails
      return username == _predefinedUsername && password == _predefinedPassword;
    }
  }

  // Update admin credentials
  Future<bool> updateAdminCredentials(String oldUsername, String oldPassword,
      String newUsername, String newPassword) async {
    try {
      final isValid = await verifyAdminLogin(oldUsername, oldPassword);
      if (isValid) {
        // In a real app, you would update the predefined values
        // For now, we'll just log the request
        print('✅ Admin credentials update requested: $newUsername');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error updating admin credentials: $e');
      return false;
    }
  }

  // Get current admin username
  String getCurrentAdminUsername() {
    return _predefinedUsername;
  }

  // Get predefined credentials (for display purposes)
  Map<String, String> getPredefinedCredentials() {
    return {
      'username': _predefinedUsername,
      'password': _predefinedPassword,
    };
  }

  // PRODUCT MANAGEMENT METHODS

  // Get all products from Firebase
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting products: $e');
      rethrow;
    }
  }

  // Add product to Firebase
  Future<void> addProduct(Map<String, dynamic> productData) async {
    try {
      await _firestore.collection('products').add({
        ...productData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add product: $e');
    }
  }

  // Update product in Firebase
  Future<void> updateProduct(
      String productId, Map<String, dynamic> productData) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        ...productData,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  // Delete product from Firebase
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }

  // ORDER MANAGEMENT METHODS

  // Get all orders for management
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .orderBy('orderDate', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting orders: $e');
      rethrow;
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get order statistics for dashboard
  Future<Map<String, dynamic>> getOrderStatistics() async {
    try {
      final ordersSnapshot = await _firestore.collection('orders').get();
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final weekStart = todayStart.subtract(const Duration(days: 7));

      int todayOrders = 0;
      int weekOrders = 0;
      int pendingOrders = 0;
      int deliveredOrders = 0;

      for (final doc in ordersSnapshot.docs) {
        final order = doc.data() as Map<String, dynamic>? ?? {};
        final orderDate =
            DateTime.fromMillisecondsSinceEpoch(order['orderDate'] ?? 0);
        final status = order['status'] as String? ?? 'pending';

        // Today's orders
        if (orderDate.isAfter(todayStart)) {
          todayOrders++;
        }

        // This week's orders
        if (orderDate.isAfter(weekStart)) {
          weekOrders++;
        }

        // Status counts
        if (status == 'pending') {
          pendingOrders++;
        } else if (status == 'delivered') {
          deliveredOrders++;
        }
      }

      return {
        'totalOrders': ordersSnapshot.size,
        'todayOrders': todayOrders,
        'weekOrders': weekOrders,
        'pendingOrders': pendingOrders,
        'deliveredOrders': deliveredOrders,
      };
    } catch (e) {
      print('Error getting order statistics: $e');
      rethrow;
    }
  }

  // REPORTS METHODS

  // Get sales reports
  Future<Map<String, dynamic>> getSalesReport(
      DateTime startDate, DateTime endDate,
      {String? category}) async {
    try {
      Query query = _firestore
          .collection('orders')
          .where('orderDate',
              isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('orderDate',
              isLessThanOrEqualTo: endDate.millisecondsSinceEpoch);

      final snapshot = await query.get();

      double totalRevenue = 0;
      int totalOrders = 0;
      int totalItems = 0;
      Map<String, double> categoryRevenue = {};
      Map<String, int> categoryOrders = {};

      for (final doc in snapshot.docs) {
        final order = doc.data() as Map<String, dynamic>? ?? {};
        final amount = (order['totalAmount'] ?? 0).toDouble();
        final items = List<dynamic>.from(order['items'] ?? []);

        totalRevenue += amount;
        totalOrders++;
        totalItems += items.fold(0, (sum, item) {
          final itemMap = item as Map<String, dynamic>? ?? {};
          return sum + (itemMap['quantity'] as int? ?? 0);
        });

        // Category-wise analysis
        for (final item in items) {
          final itemMap = item as Map<String, dynamic>? ?? {};
          final itemCategory = itemMap['category'] as String? ?? 'Unknown';
          final itemPrice = (itemMap['price'] as double? ?? 0.0) *
              (itemMap['quantity'] as int? ?? 1);

          categoryRevenue[itemCategory] =
              (categoryRevenue[itemCategory] ?? 0) + itemPrice;
          categoryOrders[itemCategory] =
              (categoryOrders[itemCategory] ?? 0) + 1;
        }
      }

      return {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'totalItems': totalItems,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0,
        'categoryRevenue': categoryRevenue,
        'categoryOrders': categoryOrders,
        'startDate': startDate,
        'endDate': endDate,
      };
    } catch (e) {
      print('Error generating sales report: $e');
      rethrow;
    }
  }

  // USER MANAGEMENT METHODS

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final ordersSnapshot = await _firestore.collection('orders').get();

      // User analysis
      final totalUsers = usersSnapshot.size;
      final usersWithOrders = <String>{};

      for (final order in ordersSnapshot.docs) {
        final orderData = order.data() as Map<String, dynamic>? ?? {};
        final userId = orderData['userId'] as String? ?? '';
        if (userId.isNotEmpty) {
          usersWithOrders.add(userId);
        }
      }

      final activeUsers = usersWithOrders.length;
      final conversionRate =
          totalUsers > 0 ? (activeUsers / totalUsers) * 100 : 0;

      // Get user list with proper typing
      final userList = usersSnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>? ?? {};
      }).toList();

      return {
        'totalUsers': totalUsers,
        'activeUsers': activeUsers,
        'conversionRate': conversionRate,
        'userList': userList,
      };
    } catch (e) {
      print('Error getting user statistics: $e');
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      // Validate userId
      if (userId.isEmpty) {
        throw Exception('Invalid user ID');
      }

      print('🔄 Updating user in Firestore: $userId');

      // Create a safe updates map that EXCLUDES email and password
      final safeUpdates = <String, dynamic>{};

      updates.forEach((key, value) {
        if (value != null &&
            value.toString().isNotEmpty &&
            value.toString() != 'null') {
          // ONLY include non-authentication fields
          // EXCLUDE email and password to prevent login issues
          if (key != 'email' && key != 'password') {
            safeUpdates[key] = value.toString();
          }
        }
      });

      // Add timestamp if provided, otherwise use server timestamp
      if (updates['updatedAt'] != null) {
        safeUpdates['updatedAt'] = updates['updatedAt'];
      } else {
        safeUpdates['updatedAt'] = FieldValue.serverTimestamp();
      }

      // Update ONLY in Firestore
      await _firestore.collection('users').doc(userId).update(safeUpdates);

      print('✅ User updated successfully in Firestore: $userId');
      print('📋 Updated fields: ${safeUpdates.keys.toList()}');
    } catch (e) {
      print('❌ Error updating user: $e');
      rethrow;
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}
