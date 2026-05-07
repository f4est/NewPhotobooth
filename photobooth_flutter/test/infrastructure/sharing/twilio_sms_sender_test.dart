import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:photobooth_flutter/src/domain/settings/app_settings.dart';
import 'package:photobooth_flutter/src/domain/sharing/sms_message.dart';
import 'package:photobooth_flutter/src/infrastructure/sharing/twilio_sms_sender.dart';

void main() {
  test('posts sms message to Twilio messages endpoint', () async {
    late http.Request captured;
    final sender = TwilioSmsSender(
      client: MockClient((request) async {
        captured = request;
        return http.Response('{"sid":"SM123"}', 201);
      }),
    );

    await sender.send(
      settings: const SharingSettings(smsSid: 'AC123', smsAuthToken: 'token'),
      message: const SmsMessage(
        from: '+15550000001',
        to: '+15550000002',
        body: 'Hello',
      ),
    );

    expect(captured.url.host, 'api.twilio.com');
    expect(captured.url.path, '/2010-04-01/Accounts/AC123/Messages.json');
    expect(captured.headers['Authorization'], startsWith('Basic '));
    expect(captured.body, contains('Body=Hello'));
  });

  test('throws when Twilio returns an error', () {
    final sender = TwilioSmsSender(
      client: MockClient((request) async => http.Response('bad', 400)),
    );

    expect(
      () => sender.send(
        settings: const SharingSettings(smsSid: 'AC123', smsAuthToken: 'token'),
        message: const SmsMessage(
          from: '+15550000001',
          to: '+15550000002',
          body: 'Hello',
        ),
      ),
      throwsStateError,
    );
  });
}
