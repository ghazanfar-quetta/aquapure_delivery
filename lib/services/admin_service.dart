import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ========= FIREBASE AUTH ADMIN METHODS =========

  // Check if current user is admin via Firebase Auth claims
  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return false;
      }

      // Get fresh token to check claims
      final idTokenResult = await user.getIdTokenResult(true);
      final isAdmin = idTokenResult.claims?['admin'] == true;

      print(
          '🔍 Admin check: UID=${user.uid}, IsAdmin=$isAdmin, Claims=${idTokenResult.claims}');
      return isAdmin;
    } catch (e) {
      print('❌ Error checking admin status: $e');
      return false;
    }
  }

  // Admin login with Firebase Auth
  Future<bool> loginAdmin(String email, String password) async {
    try {
      print('🔐 Attempting admin login for: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      print('✅ Firebase Auth login successful');
      print('👤 User UID: ${userCredential.user?.uid}');

      // Check admin claims
      final idTokenResult = await userCredential.user!.getIdTokenResult(true);
      final isAdmin = idTokenResult.claims?['admin'] == true;

      print('🔑 Admin claims check: $isAdmin');
      print('📋 Full claims: ${idTokenResult.claims}');

      return isAdmin;
    } catch (e) {
      print('❌ Admin login error: $e');
      rethrow;
    }
  }

  // Admin logout
  Future<void> logoutAdmin() async {
    await _auth.signOut();
    print('👋 Admin logged out');
  }

  // Get current admin info
  Map<String, dynamic>? getCurrentAdminInfo() {
    final user = _auth.currentUser;
    if (user == null) return null;

    return {
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName,
      'photoUrl': user.photoURL,
    };
  }

  // Get current admin email
  String? getCurrentAdminEmail() {
    return _auth.currentUser?.email;
  }

  // ========= BACKWARD COMPATIBILITY METHODS =========

  // Verify admin login (for backward compatibility)
  // Remove or update the verifyAdminLogin method
  Future<bool> verifyAdminLogin(String username, String password) async {
    try {
      // Only use Firebase Auth - no hardcoded fallback
      if (username.contains('@')) {
        return await loginAdmin(username, password);
      }
      return false; // Reject non-email logins
    } catch (e) {
      print('❌ Error in verifyAdminLogin: $e');
      return false;
    }
  }

// Remove hardcoded credentials from getPredefinedCredentials
  Map<String, String> getPredefinedCredentials() {
    return {
      'info': 'Use Firebase Auth admin credentials',
      'note': 'Contact system administrator for access',
    };
  }

  // Get current admin username (for backward compatibility)
  String getCurrentAdminUsername() {
    final email = _auth.currentUser?.email;
    if (email != null && email.contains('@')) {
      return email.split('@')[0];
    }
    return 'taskeen'; // Fallback
  }

  // ========= PRODUCT MANAGEMENT METHODS =========

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
      throw Exception('Failed to get products: $e');
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

  // ========= ORDER MANAGEMENT METHODS =========

  // Get all orders for management
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final snapshot = await _firestore.collection('orders').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get orders: $e');
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

      int pendingOrders = 0;
      int deliveredOrders = 0;
      int confirmedOrders = 0;
      int outForDeliveryOrders = 0;
      int cancelledOrders = 0;

      for (final doc in ordersSnapshot.docs) {
        final order = doc.data() as Map<String, dynamic>? ?? {};
        final status = order['status'] as String? ?? 'pending';

        if (status == 'pending') {
          pendingOrders++;
        } else if (status == 'delivered') {
          deliveredOrders++;
        } else if (status == 'confirmed') {
          confirmedOrders++;
        } else if (status == 'out_for_delivery') {
          outForDeliveryOrders++;
        } else if (status == 'cancelled') {
          cancelledOrders++;
        }
      }

      return {
        'totalOrders': ordersSnapshot.size,
        'pendingOrders': pendingOrders,
        'deliveredOrders': deliveredOrders,
        'confirmedOrders': confirmedOrders,
        'outForDeliveryOrders': outForDeliveryOrders,
        'cancelledOrders': cancelledOrders,
      };
    } catch (e) {
      throw Exception('Failed to get order statistics: $e');
    }
  }

  // ========= REPORT METHODS =========

  Future<Map<String, dynamic>> getProductWiseReport(
      DateTime startDate, DateTime endDate) async {
    try {
      // Get all products for reference
      final productsSnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      final productsMap = <String, Map<String, dynamic>>{};
      for (var doc in productsSnapshot.docs) {
        productsMap[doc.id] = {...doc.data(), 'id': doc.id};
      }

      // Get all orders (no date filtering since createdAt is null)
      final allOrdersQuery =
          await FirebaseFirestore.instance.collection('orders').get();

      final orders = allOrdersQuery.docs;

      if (orders.isEmpty) {
        return {
          'products': [],
          'totalRevenue': 0,
          'totalOrders': 0,
          'productCount': 0,
        };
      }

      // Process product-wise data
      Map<String, dynamic> productData = {};
      double totalRevenue = 0;
      int totalOrders = orders.length;

      for (var order in orders) {
        final orderData = order.data();
        final items = orderData['items'] as List<dynamic>? ?? [];

        if (items.isEmpty) continue;

        for (var item in items) {
          final productId = item['productId'] ?? item['id'] ?? '';
          if (productId.isEmpty) continue;

          final product = productsMap[productId];
          if (product == null) continue;

          final productName = product['name'] ?? 'Unknown Product';
          final category = product['category'] ?? 'Uncategorized';
          final quantity = (item['quantity'] ?? item['qty'] ?? 1) as int;
          final price = (item['price'] ?? product['price'] ?? 0).toDouble();
          final itemRevenue = quantity * price;

          totalRevenue += itemRevenue;

          if (productData[productId] == null) {
            productData[productId] = {
              'name': productName,
              'category': category,
              'quantity': quantity,
              'revenue': itemRevenue,
              'orders': 1,
            };
          } else {
            productData[productId]['quantity'] += quantity;
            productData[productId]['revenue'] += itemRevenue;
            productData[productId]['orders'] += 1;
          }
        }
      }

      final productList = productData.values.toList();
      productList.sort(
          (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

      return {
        'products': productList,
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'productCount': productList.length,
      };
    } catch (e) {
      throw Exception('Failed to generate product-wise report: $e');
    }
  }

  Future<Map<String, dynamic>> getCategoryWiseReport(
      DateTime startDate, DateTime endDate) async {
    try {
      // Get all products for category information
      final productsSnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      final productsMap = <String, Map<String, dynamic>>{};
      for (var doc in productsSnapshot.docs) {
        productsMap[doc.id] = {...doc.data(), 'id': doc.id};
      }

      // Get all orders (no date filtering since createdAt is null)
      final allOrdersQuery =
          await FirebaseFirestore.instance.collection('orders').get();

      final orders = allOrdersQuery.docs;

      if (orders.isEmpty) {
        return {
          'categories': [],
          'totalRevenue': 0,
          'totalOrders': 0,
          'categoryCount': 0,
        };
      }

      // Process category-wise data
      Map<String, dynamic> categoryData = {};
      double totalRevenue = 0;
      int totalOrders = orders.length;

      for (var order in orders) {
        final orderData = order.data();
        final items = orderData['items'] as List<dynamic>? ?? [];

        for (var item in items) {
          final productId = item['productId'] ?? item['id'] ?? '';
          if (productId.isEmpty) continue;

          final product = productsMap[productId];
          if (product == null) continue;

          final category = product['category'] ?? 'Uncategorized';
          final quantity = (item['quantity'] ?? item['qty'] ?? 1) as int;
          final price = (item['price'] ?? product['price'] ?? 0).toDouble();
          final itemRevenue = quantity * price;

          totalRevenue += itemRevenue;

          if (categoryData[category] == null) {
            categoryData[category] = {
              'name': category,
              'quantity': quantity,
              'revenue': itemRevenue,
              'orders': 1,
              'products': 1,
            };
          } else {
            categoryData[category]['quantity'] += quantity;
            categoryData[category]['revenue'] += itemRevenue;
            categoryData[category]['orders'] += 1;
            categoryData[category]['products'] += 1;
          }
        }
      }

      final categoryList = categoryData.values.toList();
      categoryList.sort(
          (a, b) => (b['revenue'] as double).compareTo(a['revenue'] as double));

      return {
        'categories': categoryList,
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'categoryCount': categoryList.length,
      };
    } catch (e) {
      throw Exception('Failed to generate category-wise report: $e');
    }
  }

  Future<Map<String, dynamic>> getSalesReport(
      DateTime startDate, DateTime endDate) async {
    try {
      // Get all orders (no date filtering since createdAt is null)
      final allOrdersQuery =
          await FirebaseFirestore.instance.collection('orders').get();

      final orders = allOrdersQuery.docs;

      double totalRevenue = 0;
      int totalOrders = orders.length;
      int totalItems = 0;

      for (var order in orders) {
        final orderData = order.data();
        final items = orderData['items'] as List<dynamic>? ?? [];
        double orderTotal = 0;

        for (var item in items) {
          final quantity = (item['quantity'] ?? 0) as int;
          final price = (item['price'] ?? 0).toDouble();
          orderTotal += quantity * price;
          totalItems += quantity;
        }

        totalRevenue += orderTotal;
      }

      final averageOrderValue =
          orders.isNotEmpty ? totalRevenue / orders.length : 0;

      return {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'totalItems': totalItems,
        'averageOrderValue': averageOrderValue,
      };
    } catch (e) {
      throw Exception('Failed to generate sales report: $e');
    }
  }

  // ========= USER MANAGEMENT METHODS =========

  // Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final ordersSnapshot = await _firestore.collection('orders').get();

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
      throw Exception('Failed to get user statistics: $e');
    }
  }

  // Update user (with improved error handling)
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      if (userId.isEmpty) {
        throw Exception('Invalid user ID');
      }

      final safeUpdates = <String, dynamic>{};

      updates.forEach((key, value) {
        if (value != null &&
            value.toString().isNotEmpty &&
            value.toString() != 'null') {
          if (key != 'email' && key != 'password') {
            safeUpdates[key] = value.toString();
          }
        }
      });

      if (updates['updatedAt'] != null) {
        safeUpdates['updatedAt'] = updates['updatedAt'];
      } else {
        safeUpdates['updatedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('users').doc(userId).update(safeUpdates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}
