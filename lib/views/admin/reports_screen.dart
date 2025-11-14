import 'package:flutter/material.dart';
import 'package:aquapure_delivery/services/admin_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final AdminService _adminService = AdminService();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _reportType = 'sales';
  Map<String, dynamic>? _currentReport;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Report Controls
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Report Type Selection
                  DropdownButtonFormField<String>(
                    value: _reportType,
                    decoration: const InputDecoration(
                      labelText: 'Report Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'sales', child: Text('Sales Report')),
                      DropdownMenuItem(
                          value: 'products',
                          child: Text('Product-wise Report')),
                      DropdownMenuItem(
                          value: 'categories',
                          child: Text('Category-wise Report')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _reportType = value!;
                        _currentReport =
                            null; // Clear previous report when type changes
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Range Selection
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Date'),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _selectStartDate(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${_startDate.toLocal()}'.split(' ')[0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Date'),
                            const SizedBox(height: 4),
                            InkWell(
                              onTap: () => _selectEndDate(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${_endDate.toLocal()}'.split(' ')[0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Generate Report Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isGenerating ? null : _generateReport,
                      icon: _isGenerating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.analytics),
                      label: Text(
                          _isGenerating ? 'Generating...' : 'Generate Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Report Results
          if (_currentReport != null) _buildReportSummary(),

          // Product-wise or Category-wise details
          if (_currentReport != null && _reportType != 'sales')
            _buildDetailedReport(),
        ],
      ),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _endDate = date;
      });
    }
  }

  Future<void> _generateReport() async {
    try {
      setState(() => _isGenerating = true);

      Map<String, dynamic> report;

      // Call different methods based on report type
      switch (_reportType) {
        case 'products':
          report =
              await _adminService.getProductWiseReport(_startDate, _endDate);
          break;
        case 'categories':
          report =
              await _adminService.getCategoryWiseReport(_startDate, _endDate);
          break;
        case 'sales':
        default:
          report = await _adminService.getSalesReport(_startDate, _endDate);
          break;
      }

      setState(() {
        _currentReport = report;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildReportSummary() {
    if (_currentReport == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_reportType.replaceFirst(_reportType[0], _reportType[0].toUpperCase())} Summary',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_reportType == 'sales') _buildSalesSummary(),
            if (_reportType == 'products') _buildProductsSummary(),
            if (_reportType == 'categories') _buildCategoriesSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesSummary() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildReportCard(index);
      },
    );
  }

  Widget _buildProductsSummary() {
    final products = _currentReport!['products'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Products: ${products.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Total Revenue: Rs. ${(_currentReport!['totalRevenue'] ?? 0).toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildCategoriesSummary() {
    final categories = _currentReport!['categories'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Categories: ${categories.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Total Revenue: Rs. ${(_currentReport!['totalRevenue'] ?? 0).toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildDetailedReport() {
    if (_reportType == 'sales') return const SizedBox();

    final items = _reportType == 'products'
        ? _currentReport!['products'] as List<dynamic>? ?? []
        : _currentReport!['categories'] as List<dynamic>? ?? [];

    if (items.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No data available for the selected period.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _reportType == 'products'
                  ? 'Product Details'
                  : 'Category Details',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildReportItem(item, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text('Quantity: ${item['quantity'] ?? 0}'),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${(item['revenue'] ?? 0).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
              Text('${item['orders'] ?? 0} orders'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(int index) {
    final List<Map<String, dynamic>> reportData = [
      {
        'title': 'Total Revenue',
        'value':
            'Rs. ${(_currentReport!['totalRevenue'] ?? 0).toStringAsFixed(2)}',
        'color': Colors.green,
      },
      {
        'title': 'Total Orders',
        'value': '${_currentReport!['totalOrders'] ?? 0}',
        'color': Colors.blue,
      },
      {
        'title': 'Total Items',
        'value': '${_currentReport!['totalItems'] ?? 0}',
        'color': Colors.orange,
      },
      {
        'title': 'Avg. Order Value',
        'value':
            'Rs. ${(_currentReport!['averageOrderValue'] ?? 0).toStringAsFixed(2)}',
        'color': Colors.purple,
      },
    ];

    final data = reportData[index];
    return Card(
      color: data['color'] as Color,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              data['value'] as String,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              data['title'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
