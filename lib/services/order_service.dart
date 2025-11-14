import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aquapure_delivery/models/order_model.dart';
import 'package:aquapure_delivery/models/cart_item_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Place a new order
  Future<void> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
    required String deliveryAddress,
  }) async {
    try {
      print('🔄 Starting order placement...');
      print('📦 User ID: $userId');
      print('📦 Items count: ${items.length}');
      print('💰 Total amount: $totalAmount');
      print('🏠 Delivery address: $deliveryAddress');

      final orderRef = _firestore.collection('orders').doc();

      final order = OrderModel(
        id: orderRef.id,
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        status: 'pending',
        deliveryAddress: deliveryAddress,
        orderDate: DateTime.now(),
      );

      print('📝 Order data: ${order.toMap()}');

      await orderRef.set(order.toMap());
      print('✅ Order placed successfully: ${orderRef.id}');
    } catch (e) {
      print('❌ Error placing order: $e');
      rethrow;
    }
  }

  // Get user's orders - PERMANENT OPTIMIZED VERSION
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        if (status == 'delivered')
          'deliveryDate': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ Order status updated: $orderId -> $status');
    } catch (e) {
      print('❌ Error updating order status: $e');
      rethrow;
    }
  }

  // Get single order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error getting order: $e');
      return null;
    }
  }
}
