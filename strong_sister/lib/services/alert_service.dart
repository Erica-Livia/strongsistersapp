import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AlertService {
  final String accountSid = dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
  final String authToken = dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
  final String fromWhatsAppNumber = 'whatsapp:+14155238886';
  final String teamWhatsAppNumber = 'whatsapp:+250790137395';

  Future<void> sendEmergencyAlert(String phoneNumber, String userName,
      String latitude, String longitude) async {
    final Uri url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');

    final Map<String, String> headers = {
      'Authorization':
          'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    // Google Maps URL format
    final String locationUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

    final Map<String, String> body = {
      'From': fromWhatsAppNumber,
      'To': teamWhatsAppNumber,
      'Body':
          'Emergency Alert from $userName! I may be in danger. Here is my location: $locationUrl',
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        print('WhatsApp alert sent successfully');
      } else {
        print('Failed to send WhatsApp alert: ${response.body}');
      }
    } catch (e) {
      print('Error sending WhatsApp alert: $e');
    }
  }
}
