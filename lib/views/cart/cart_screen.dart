import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aquapure_delivery/models/cart_item_model.dart';
import 'package:aquapure_delivery/services/cart_service.dart';
import 'package:aquapure_delivery/services/order_service.dart';
import 'package:aquapure_delivery/services/auth_service.dart'; // ADD THIS LINE

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // REMOVED: final CartService _cartService = CartService();

  @override
  Widget build(BuildContext context) {
    final cartService =
        Provider.of<CartService>(context); // ADDED: Use Provider
    final cartItems = cartService.cartItems; // CHANGED: Use from Provider
    final totalPrice = cartService.totalPrice; // CHANGED: Use from Provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Cart items list
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add some water bottles to get started!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(
                          item, cartService); // CHANGED: Pass cartService
                    },
                    cacheExtent: 500,
                    addAutomaticKeepAlives: true,
                    addRepaintBoundaries: true,
                  ),
          ),

          // Checkout section
          if (cartItems.isNotEmpty)
            _buildCheckoutSection(
                totalPrice, cartService), // CHANGED: Pass cartService
        ],
      ),
    );
  }

  // CHANGED: Accept cartService as parameter
  Widget _buildCartItem(CartItem item, CartService cartService) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Product image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.water_drop,
                color: Colors.blue.shade300,
              ),
            ),
            const SizedBox(width: 16),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.size}L • Rs.${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Quantity controls
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              cartService.updateQuantity(
                                  // CHANGED: Use from Provider
                                  item.productId,
                                  item.quantity - 1);
                            });
                          },
                          icon: const Icon(Icons.remove, size: 14),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              cartService.updateQuantity(
                                  // CHANGED: Use from Provider
                                  item.productId,
                                  item.quantity + 1);
                            });
                          },
                          icon: const Icon(Icons.add,
                              size: 14, color: Colors.white),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Price and remove
            SizedBox(
              width: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Rs.${item.totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        cartService.removeFromCart(
                            item.productId); // CHANGED: Use from Provider
                      });
                    },
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CHANGED: Accept cartService as parameter
  Widget _buildCheckoutSection(double totalPrice, CartService cartService) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rs.${totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                _showCheckoutDialog(
                    totalPrice, cartService); // CHANGED: Pass cartService
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CHANGED: Accept cartService as parameter
  void _showCheckoutDialog(double totalPrice, CartService cartService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your order summary:'),
            const SizedBox(height: 8),
            Text(
                'Total Items: ${cartService.totalItems}'), // CHANGED: Use from Provider
            Text('Total Amount: Rs.${totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            const Text(
              'Delivery will arrive within 2 hours!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _placeOrder(totalPrice, cartService); // CHANGED: Pass cartService
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
            ),
            child: const Text('Confirm Order'),
          ),
        ],
      ),
    );
  }

  void _placeOrder(double totalPrice, CartService cartService) async {
    final authService = AuthService();

    // Check if user is logged in
    if (!authService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to place an order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = authService.currentUserId;
    final userData = authService.currentUserData;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User session expired. Please sign in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final orderService = OrderService();

      await orderService.placeOrder(
        userId: userId,
        items: cartService.cartItems,
        totalAmount: totalPrice,
        deliveryAddress: userData?['address'] ?? 'Address not provided',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Clear cart after order
      cartService.clearCart();

      // Navigate back to home
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('🔥 Order placement error: $e');
    }
  }
}
