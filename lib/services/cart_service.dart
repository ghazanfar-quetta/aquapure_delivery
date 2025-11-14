import 'package:flutter/material.dart';
import 'package:aquapure_delivery/models/product_model.dart';
import 'package:aquapure_delivery/models/cart_item_model.dart';

class CartService extends ChangeNotifier {
  List<CartItem> _cartItems = [];

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex =
        _cartItems.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      // ✅ quantity always int
      final updatedQty = _cartItems[existingIndex].quantity + quantity;

      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: updatedQty,
      );
    } else {
      _cartItems.add(
        CartItem(
          productId: product.id,
          productName: product.name,
          price: (product.price as num).toDouble(), // ✅ ensure double
          imageUrl: product.imageUrl,
          quantity: quantity,
          size: (product.size as num).toInt(), // ✅ ensure int
        ),
      );
    }

    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _cartItems.indexWhere((item) => item.productId == productId);

    if (index >= 0) {
      if (quantity <= 0) {
        removeFromCart(productId);
      } else {
        _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _cartItems.any((item) => item.productId == productId);
  }

  int getQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        productId: '',
        productName: '',
        price: 0,
        imageUrl: '',
        quantity: 0,
        size: 0,
      ),
    );
    return item.quantity;
  }
}
