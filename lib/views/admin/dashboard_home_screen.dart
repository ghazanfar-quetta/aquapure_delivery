import 'package:flutter/material.dart';
import 'package:aquapure_delivery/services/admin_service.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final AdminService _adminService = AdminService();
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final stats = await _adminService.getOrderStatistics();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load statistics: $e';
      });
      print('Error loading stats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Header
          const Text(
            'Admin Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back! Here\'s your business overview.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),

          // Error Message
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade800),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.red.shade600),
                    onPressed: _loadStats,
                  ),
                ],
              ),
            ),

          if (_error != null) const SizedBox(height: 16),

          // Statistics Cards
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    return _buildStatCard(index);
                  },
                ),
          const SizedBox(height: 20),

          // Bar Chart Section - REPLACED Pie Chart
          const Text(
            'Order Status Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildBarChartSection(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(int index) {
    final List<Map<String, dynamic>> stats = [
      {
        'title': 'Total Orders',
        'value': '${_stats['totalOrders'] ?? 0}',
        'icon': Icons.shopping_cart,
        'color': Colors.blue,
      },
      {
        'title': 'Today\'s Orders',
        'value': '${_stats['todayOrders'] ?? 0}',
        'icon': Icons.today,
        'color': Colors.green,
      },
      {
        'title': 'Pending Orders',
        'value': '${_stats['pendingOrders'] ?? 0}',
        'icon': Icons.pending_actions,
        'color': Colors.orange,
      },
      {
        'title': 'Delivered',
        'value': '${_stats['deliveredOrders'] ?? 0}',
        'icon': Icons.check_circle,
        'color': Colors.purple,
      },
    ];

    final stat = stats[index];
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              stat['icon'] as IconData,
              color: stat['color'] as Color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              stat['value'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat['title'] as String,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartSection() {
    final totalOrders = _stats['totalOrders'] ?? 0;
    final todayOrders = _stats['todayOrders'] ?? 0;
    final pendingOrders = _stats['pendingOrders'] ?? 0;
    final deliveredOrders = _stats['deliveredOrders'] ?? 0;

    // Get max value for scaling
    final maxValue = [totalOrders, todayOrders, pendingOrders, deliveredOrders]
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Bar Chart
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue > 0 ? maxValue * 1.2 : 10, // Add some padding
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final title = _getBarTitle(groupIndex);
                        final value = rod.toY.toInt();
                        return BarTooltipItem(
                          '$title\n$value orders',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _getBarTitle(value.toInt()),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max ||
                              value % (maxValue ~/ 3 + 1) == 0) {
                            return Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: totalOrders.toDouble(),
                          color: Colors.blue,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: todayOrders.toDouble(),
                          color: Colors.green,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: pendingOrders.toDouble(),
                          color: Colors.orange,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: deliveredOrders.toDouble(),
                          color: Colors.purple,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Legend matching the business overview colors
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegendItem(Colors.blue, 'Total', totalOrders),
                _buildLegendItem(Colors.green, 'Today', todayOrders),
                _buildLegendItem(Colors.orange, 'Pending', pendingOrders),
                _buildLegendItem(Colors.purple, 'Delivered', deliveredOrders),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Total';
      case 1:
        return 'Today';
      case 2:
        return 'Pending';
      case 3:
        return 'Delivered';
      default:
        return '';
    }
  }

  Widget _buildLegendItem(Color color, String label, int value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
