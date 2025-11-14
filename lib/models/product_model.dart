class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final String category;
  final double size; // in liters

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
    required this.size,
  });

  String get formattedPrice => 'Rs. ${price.toStringAsFixed(2)}';
  String get sizeLabel => '${size.toStringAsFixed(1)}L';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
      'category': category,
      'size': size,
    };
  }

  factory Product.fromMap(String id, Map<String, dynamic> map) {
    return Product(
      id: id,
      name: map['name']?.toString() ?? 'Unnamed Product',
      description: map['description']?.toString() ?? '',
      price: _parseDouble(map['price']),
      imageUrl: map['imageUrl']?.toString() ?? '',
      stock: _parseInt(map['stock']),
      category: map['category']?.toString() ?? 'Uncategorized',
      size: _parseDouble(map['size']),
    );
  }

  // Helper methods to handle different data types from Firebase
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
