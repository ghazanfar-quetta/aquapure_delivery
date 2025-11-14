import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getCompanyInfo() async {
    try {
      final doc =
          await _firestore.collection('company').doc('contact_info').get();
      if (doc.exists) {
        return doc.data()!;
      } else {
        return {
          'supportPhone': '+92 300 1234567',
          'whatsappNumber': '+92 300 1234567',
          'supportEmail': 'support@aquapure.com',
          'companyName': 'AquaPure Delivery',
          'businessHours': '8:00 AM - 10:00 PM',
          'appVersion': '1.0.0',
          'flutterVersion': '3.0.0+',
          'lastUpdated': 'December 2023',
          'developerName': 'AquaPure Team',
        };
      }
    } catch (e) {
      print('Error fetching company info: $e');
      return {
        'supportPhone': '+92 300 1234567',
        'whatsappNumber': '+92 300 1234567',
        'supportEmail': 'support@aquapure.com',
        'companyName': 'AquaPure Delivery',
        'businessHours': '8:00 AM - 10:00 PM',
        'appVersion': '1.0.0',
        'lastUpdated': 'December 2023',
        'developerName': 'AquaPure Team',
      };
    }
  }
}
