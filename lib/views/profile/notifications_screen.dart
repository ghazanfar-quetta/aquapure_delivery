import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aquapure_delivery/services/auth_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _orderUpdates = true;
  bool _promotions = true;
  bool _deliveryStatus = true;
  bool _specialOffers = false;
  bool _newsletter = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final userId = _authService.currentUserId;

    if (userId == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final notifications =
            userData['notifications'] as Map<String, dynamic>? ?? {};

        setState(() {
          _orderUpdates = notifications['orderUpdates'] ?? true;
          _promotions = notifications['promotions'] ?? true;
          _deliveryStatus = notifications['deliveryStatus'] ?? true;
          _specialOffers = notifications['specialOffers'] ?? false;
          _newsletter = notifications['newsletter'] ?? false;
        });
      }
    } catch (e) {
      print('Error loading notification settings: $e');
    }
  }

  Future<void> _saveNotificationSettings() async {
    final userId = _authService.currentUserId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found. Please sign in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final notificationSettings = {
        'orderUpdates': _orderUpdates,
        'promotions': _promotions,
        'deliveryStatus': _deliveryStatus,
        'specialOffers': _specialOffers,
        'newsletter': _newsletter,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(userId).update({
        'notifications': notificationSettings,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification preferences saved successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Manage your notification preferences. Settings are saved to your account.',
                      style: TextStyle(
                        color: Colors.blue.shade800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notification Settings
            Text(
              'Push Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what notifications you want to receive',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Notification Options
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationOption(
                    title: 'Order Updates',
                    subtitle: 'Order confirmations and status changes',
                    value: _orderUpdates,
                    onChanged: (value) {
                      setState(() {
                        _orderUpdates = value ?? true;
                      });
                    },
                    icon: Icons.shopping_bag,
                  ),
                  _buildNotificationOption(
                    title: 'Delivery Status',
                    subtitle: 'Real-time delivery tracking updates',
                    value: _deliveryStatus,
                    onChanged: (value) {
                      setState(() {
                        _deliveryStatus = value ?? true;
                      });
                    },
                    icon: Icons.delivery_dining,
                  ),
                  _buildNotificationOption(
                    title: 'Promotions & Discounts',
                    subtitle: 'Special offers and discount coupons',
                    value: _promotions,
                    onChanged: (value) {
                      setState(() {
                        _promotions = value ?? true;
                      });
                    },
                    icon: Icons.local_offer,
                  ),
                  _buildNotificationOption(
                    title: 'Special Offers',
                    subtitle: 'Exclusive deals and limited-time offers',
                    value: _specialOffers,
                    onChanged: (value) {
                      setState(() {
                        _specialOffers = value ?? false;
                      });
                    },
                    icon: Icons.star,
                  ),
                  _buildNotificationOption(
                    title: 'Newsletter',
                    subtitle: 'Weekly updates and water tips',
                    value: _newsletter,
                    onChanged: (value) {
                      setState(() {
                        _newsletter = value ?? false;
                      });
                    },
                    icon: Icons.email,
                  ),
                ],
              ),
            ),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveNotificationSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Save Preferences',
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
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade700,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue.shade700,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
