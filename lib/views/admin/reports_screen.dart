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
      final report = await _adminService.getSalesReport(_startDate, _endDate);
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
            const Text(
              'Report Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
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
            ),
          ],
        ),
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
