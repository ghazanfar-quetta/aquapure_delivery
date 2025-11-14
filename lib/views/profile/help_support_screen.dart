import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aquapure_delivery/services/company_service.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final CompanyService _companyService = CompanyService();
  Map<String, dynamic> _companyInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyInfo();
  }

  Future<void> _loadCompanyInfo() async {
    try {
      final companyInfo = await _companyService.getCompanyInfo();
      setState(() {
        _companyInfo = companyInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri telLaunchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    if (await canLaunchUrl(telLaunchUri)) {
      await launchUrl(telLaunchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=AquaPure Delivery Support&body=Hello AquaPure Team,',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch $email';
    }
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri whatsappLaunchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phoneNumber,
      query: 'text=Hello AquaPure Team, I need help with my order.',
    );

    if (await canLaunchUrl(whatsappLaunchUri)) {
      await launchUrl(whatsappLaunchUri);
    } else {
      throw 'Could not launch WhatsApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.help_outline,
                          color: Colors.blue.shade700,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'We\'re here to help!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Get quick assistance with your orders and account',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Methods
                  Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Support
                  _buildContactCard(
                    icon: Icons.phone,
                    title: 'Call Us',
                    subtitle: 'Speak directly with our support team',
                    contact: _companyInfo['supportPhone'] ?? '+92 300 1234567',
                    onTap: () => _launchPhone(
                        _companyInfo['supportPhone'] ?? '+923001234567'),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),

                  // WhatsApp Support
                  _buildContactCard(
                    icon: Icons.chat,
                    title: 'WhatsApp',
                    subtitle: 'Quick chat support',
                    contact:
                        _companyInfo['whatsappNumber'] ?? '+92 300 1234567',
                    onTap: () => _launchWhatsApp(_cleanPhoneNumber(
                        _companyInfo['whatsappNumber'] ?? '923001234567')),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),

                  // Email Support
                  _buildContactCard(
                    icon: Icons.email,
                    title: 'Email Us',
                    subtitle: 'Send us your queries',
                    contact:
                        _companyInfo['supportEmail'] ?? 'support@aquapure.com',
                    onTap: () => _launchEmail(
                        _companyInfo['supportEmail'] ?? 'support@aquapure.com'),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),

                  // FAQ Section
                  Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFAQItem(
                    question: 'How long does delivery take?',
                    answer:
                        'Delivery usually takes 1-2 hours during business hours (8 AM - 10 PM).',
                  ),
                  _buildFAQItem(
                    question: 'What are your delivery charges?',
                    answer:
                        'Delivery is free for orders above ₹500. Below ₹500, a ₹50 delivery charge applies.',
                  ),
                  _buildFAQItem(
                    question: 'Can I change my delivery address?',
                    answer:
                        'Yes, you can update your delivery address in the Profile section before placing an order.',
                  ),
                  _buildFAQItem(
                    question: 'What payment methods do you accept?',
                    answer:
                        'We accept cash on delivery, credit/debit cards, and mobile payments.',
                  ),
                  _buildFAQItem(
                    question: 'Do you offer bulk discounts?',
                    answer:
                        'Yes, we offer special discounts for bulk orders. Contact our sales team for details.',
                  ),
                  const SizedBox(height: 24),

                  // Business Hours
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Support Hours',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildBusinessHour(
                            'Monday - Friday',
                            _companyInfo['businessHours'] ??
                                '8:00 AM - 10:00 PM'),
                        _buildBusinessHour(
                            'Saturday - Sunday', '9:00 AM - 8:00 PM'),
                        _buildBusinessHour(
                            'Emergency Support', '24/7 Available'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _cleanPhoneNumber(String phone) {
    // Remove any non-digit characters except +
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String contact,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              contact,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward,
            color: Colors.white,
            size: 20,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessHour(String day, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
