class CartItem {
  final String productId;
  final String productName;
  final double price;
  final String imageUrl;
  final int quantity;
  final int size;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.size,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] is num)
          ? (map['price'] as num).toDouble()
          : double.tryParse(map['price']?.toString() ?? '0') ?? 0.0,
      imageUrl: map['imageUrl'] ?? '',
      quantity: (map['quantity'] is num)
          ? (map['quantity'] as num).toInt()
          : int.tryParse(map['quantity']?.toString() ?? '0') ?? 0,
      size: (map['size'] is num)
          ? (map['size'] as num).toInt()
          : int.tryParse(map['size']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'size': size,
    };
  }

  double get totalPrice => price * quantity;

  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    String? imageUrl,
    int? quantity,
    int? size,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
    );
  }
}
