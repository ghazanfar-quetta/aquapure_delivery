import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aquapure_delivery/services/company_service.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen> {
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About App'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // App Logo and Name
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.local_drink,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _companyInfo['companyName'] ?? 'AquaPure Delivery',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mineral Water Delivery App',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // App Description
                  _buildSection(
                    title: 'About AquaPure',
                    content:
                        'AquaPure Delivery is your trusted partner for pure mineral water delivery. We bring fresh, clean drinking water directly to your doorstep with just a few taps on your phone.\n\nOur mission is to provide convenient, reliable, and fast water delivery service while maintaining the highest quality standards.',
                    icon: Icons.info,
                  ),
                  const SizedBox(height: 24),

                  // Features
                  _buildSection(
                    title: 'App Features',
                    content: '',
                    icon: Icons.star,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureItem(
                      '🚚 Fast Delivery', 'Get water delivered within 2 hours'),
                  _buildFeatureItem(
                      '💧 Pure Quality', '100% natural mineral water'),
                  _buildFeatureItem(
                      '📱 Easy Ordering', 'Simple and intuitive interface'),
                  _buildFeatureItem(
                      '🔒 Secure Payments', 'Multiple payment options'),
                  _buildFeatureItem(
                      '📦 Order Tracking', 'Real-time order status updates'),
                  _buildFeatureItem(
                      '👤 User Profiles', 'Personalized delivery experience'),
                  const SizedBox(height: 24),

                  // Version Info
                  _buildSection(
                    title: 'Version Information',
                    content: '',
                    icon: Icons.phone_android,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildVersionItem('App Version',
                            _companyInfo['appVersion'] ?? '1.0.0'),
                        _buildVersionItem('Last Updated',
                            _companyInfo['lastUpdated'] ?? 'December 2023'),
                        _buildVersionItem('Developer',
                            _companyInfo['developerName'] ?? 'AquaPure Team'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Contact Info
                  _buildSection(
                    title: 'Contact Us',
                    content:
                        'Have questions or feedback? We\'d love to hear from you!',
                    icon: Icons.contact_support,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildContactItem(
                          Icons.phone,
                          'Phone',
                          _companyInfo['supportPhone'] ?? '+92 300 1234567',
                          () => _launchUrl(
                              'tel:${_companyInfo['supportPhone'] ?? '+923001234567'}'),
                        ),
                        _buildContactItem(
                          Icons.email,
                          'Email',
                          _companyInfo['supportEmail'] ??
                              'support@aquapure.com',
                          () => _launchUrl(
                              'mailto:${_companyInfo['supportEmail'] ?? 'support@aquapure.com'}'),
                        ),
                        _buildContactItem(
                          Icons.language,
                          'Website',
                          'www.aquapure.com',
                          () => _launchUrl('https://www.aquapure.com'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Legal
                  _buildSection(
                    title: 'Legal',
                    content: '',
                    icon: Icons.security,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to privacy policy
                        },
                        child: const Text('Privacy Policy'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to terms of service
                        },
                        child: const Text('Terms of Service'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Copyright
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          '© 2023 AquaPure Delivery',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'All rights reserved',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.blue.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        if (content.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeatureItem(String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
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
    );
  }

  Widget _buildVersionItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon, String title, String value, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: Colors.blue.shade700,
        size: 20,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }
}
