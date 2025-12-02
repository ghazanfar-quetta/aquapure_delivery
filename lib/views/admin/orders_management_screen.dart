import 'package:flutter/material.dart';
import 'package:aquapure_delivery/services/admin_service.dart';

class OrdersManagementScreen extends StatefulWidget {
  const OrdersManagementScreen({super.key});

  @override
  State<OrdersManagementScreen> createState() => _OrdersManagementScreenState();
}

class _OrdersManagementScreenState extends State<OrdersManagementScreen> {
  final AdminService _adminService = AdminService();
  List<Map<String, dynamic>> _orders = [];
  String _filterStatus = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      setState(() => _isLoading = true);
      final orders = await _adminService.getAllOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error loading orders: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _adminService.updateOrderStatus(orderId, newStatus);
      _loadOrders();
      _showSuccessSnackBar('Order status updated to $newStatus');
    } catch (e) {
      _showErrorSnackBar('Error updating order: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_filterStatus == 'all') return _orders;
    return _orders.where((order) => order['status'] == _filterStatus).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Orders Management',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<String>(
                    value: _filterStatus,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(
                          value: 'pending', child: Text('Pending')),
                      DropdownMenuItem(
                          value: 'confirmed', child: Text('Confirmed')),
                      DropdownMenuItem(
                        value: 'out_for_delivery',
                        child: Text('Out for Delivery'),
                      ),
                      DropdownMenuItem(
                          value: 'delivered', child: Text('Delivered')),
                      DropdownMenuItem(
                          value: 'cancelled', child: Text('Cancelled')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filterStatus = value!;
                      });
                    },
                  ),
                ],
              ),
              // Your existing orders list/content goes here
            ],
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : _filteredOrders.isEmpty
                  ? const Expanded(
                      child: Center(
                        child: Text('No orders found'),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = _filteredOrders[index];
                          return OrderCard(
                            order: order,
                            onStatusUpdate: (newStatus) {
                              _updateOrderStatus(order['id'], newStatus);
                            },
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final Function(String) onStatusUpdate;

  const OrderCard({
    super.key,
    required this.order,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final orderId = order['id']?.toString() ?? 'N/A';
    final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #$shortId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                DropdownButton<String>(
                  value: order['status']?.toString() ?? 'pending',
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(
                        value: 'confirmed', child: Text('Confirmed')),
                    DropdownMenuItem(
                        value: 'out_for_delivery',
                        child: Text('Out for Delivery')),
                    DropdownMenuItem(
                        value: 'delivered', child: Text('Delivered')),
                    DropdownMenuItem(
                        value: 'cancelled', child: Text('Cancelled')),
                  ],
                  onChanged: (newStatus) {
                    if (newStatus != null) {
                      onStatusUpdate(newStatus);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Customer: ${order['customerName'] ?? 'Unknown'}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              'Total: Rs. ${(order['totalAmount'] ?? 0).toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (order['orderDate'] != null)
              Text(
                'Date: ${DateTime.fromMillisecondsSinceEpoch(order['orderDate']).toLocal().toString().split(' ').first}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }
}
