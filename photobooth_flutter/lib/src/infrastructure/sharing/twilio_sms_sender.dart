import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/settings/app_settings.dart';
import '../../domain/sharing/sms_message.dart';
import '../../domain/sharing/sms_sender.dart';

class TwilioSmsSender implements SmsSender {
  TwilioSmsSender({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<void> send({
    required SharingSettings settings,
    required SmsMessage message,
  }) async {
    final sid = settings.smsSid.trim();
    final token = settings.smsAuthToken.trim();
    final response = await _client.post(
      Uri.https('api.twilio.com', '/2010-04-01/Accounts/$sid/Messages.json'),
      headers: {
        'Authorization': 'Basic ${base64Encode(utf8.encode('$sid:$token'))}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'From': message.from, 'To': message.to, 'Body': message.body},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError(
        'SMS provider returned ${response.statusCode}: ${response.body}',
      );
    }
  }
}
