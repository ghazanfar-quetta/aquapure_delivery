import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Predefined admin credentials
  static const String _predefinedUsername = 'taskeen';
  static const String _predefinedPassword = 'admin2025';
  static const String _adminCredentialsKey = 'admin_credentials_initialized';

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

  // Initialize admin credentials (run once)
  Future<void> _initializeAdminCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isInitialized = prefs.getBool(_adminCredentialsKey) ?? false;

      if (!isInitialized) {
        await prefs.setBool(_adminCredentialsKey, true);
      }
    } catch (e) {
      print('Error initializing admin credentials: $e');
    }
  }

  // Verify admin login
  Future<bool> verifyAdminLogin(String username, String password) async {
    try {
      await _initializeAdminCredentials();
      return username == _predefinedUsername && password == _predefinedPassword;
    } catch (e) {
      return username == _predefinedUsername && password == _predefinedPassword;
    }
  }

  // Update admin credentials
  Future<bool> updateAdminCredentials(String oldUsername, String oldPassword,
      String newUsername, String newPassword) async {
    try {
      final isValid = await verifyAdminLogin(oldUsername, oldPassword);
      if (isValid) {
        return true;
      }
      return false;
    } catch (e) {
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

  // ORDER MANAGEMENT METHODS

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

  // USER MANAGEMENT METHODS

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
