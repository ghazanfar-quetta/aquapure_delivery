import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final String deliveryAddress;
  final DateTime orderDate;
  final DateTime? deliveryDate;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.orderDate,
    this.deliveryDate,
  });

  String get formattedTotalAmount => 'Rs.${totalAmount.toStringAsFixed(2)}';
  String get formattedOrderDate =>
      '${orderDate.day}/${orderDate.month}/${orderDate.year}';
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'orderDate': orderDate.millisecondsSinceEpoch,
      'deliveryDate': deliveryDate?.millisecondsSinceEpoch,
    };
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      userId: map['userId'] ?? '',
      items: List<CartItem>.from(
        (map['items'] ?? []).map((item) => CartItem.fromMap(item)),
      ),
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'pending',
      deliveryAddress: map['deliveryAddress'] ?? '',
      orderDate: DateTime.fromMillisecondsSinceEpoch(map['orderDate'] ?? 0),
      deliveryDate: map['deliveryDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['deliveryDate'])
          : null,
    );
  }
}
