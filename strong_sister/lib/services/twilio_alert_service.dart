import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TwilioAlertService {
  final String _accountSid = dotenv.env['TWILIO_ACCOUNT_SID'] ?? '';
  final String _authToken = dotenv.env['TWILIO_AUTH_TOKEN'] ?? '';
  final String _twilioNumber = dotenv.env['TWILIO_PHONE_NUMBER'] ?? '';

  Future<void> sendWhatsApp(String to, String message) async {
    final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$_accountSid/Messages.json');
    final credentials = '$_accountSid:$_authToken';
    final headers = {
      'Authorization': 'Basic ' + base64Encode(utf8.encode(credentials)),
    };
    final body = {
      'From': 'whatsapp:$_twilioNumber',
      'To': 'whatsapp:$to',
      'Body': message,
    };

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 201) {
      print('WhatsApp message sent successfully!');
    } else {
      print('Failed to send WhatsApp message: ${response.body}');
    }
  }
}
