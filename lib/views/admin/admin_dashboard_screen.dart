import 'package:flutter/material.dart';
import 'package:aquapure_delivery/services/admin_service.dart';
import 'package:aquapure_delivery/views/admin/dashboard_home_screen.dart';
import 'package:aquapure_delivery/views/admin/products_management_screen.dart';
import 'package:aquapure_delivery/views/admin/orders_management_screen.dart';
import 'package:aquapure_delivery/views/admin/users_management_screen.dart';
import 'package:aquapure_delivery/views/admin/reports_screen.dart';
import 'package:aquapure_delivery/views/auth/login_screen.dart'; // Add your regular login screen

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  int _currentIndex = 0;
  bool _isAdmin = true; // Assume admin until verified

  @override
  void initState() {
    super.initState();
    _verifyAdminStatus();
  }

  Future<void> _verifyAdminStatus() async {
    final isAdmin = await _adminService.isCurrentUserAdmin();
    if (!isAdmin && mounted) {
      // Redirect to login if not admin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  final List<Widget> _screens = [
    const DashboardHomeScreen(),
    const ProductsManagementScreen(),
    const OrdersManagementScreen(),
    const UsersManagementScreen(),
    const ReportsScreen(),
  ];

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _adminService.logoutAdmin();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Display admin email if available
          if (_adminService.getCurrentAdminEmail() != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Text(
                  _adminService.getCurrentAdminEmail()!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey.shade600,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
