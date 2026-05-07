import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/sharing/send_test_sms.dart';
import 'package:photobooth_flutter/src/domain/settings/app_settings.dart';
import 'package:photobooth_flutter/src/domain/sharing/sms_message.dart';
import 'package:photobooth_flutter/src/domain/sharing/sms_sender.dart';

void main() {
  test('sends test sms using configured Twilio settings', () async {
    final sender = _FakeSmsSender();
    final useCase = SendTestSms(sender: sender);

    const settings = SharingSettings(
      smsEnabled: true,
      smsSid: 'AC123',
      smsAuthToken: 'token',
      smsFromNumber: '+15550000001',
      smsTestNumber: '+15550000002',
    );

    await useCase(settings);

    expect(sender.lastSettings, settings);
    expect(sender.lastMessage?.from, '+15550000001');
    expect(sender.lastMessage?.to, '+15550000002');
    expect(sender.lastMessage?.body, contains('NewPhotobooth'));
  });

  test('rejects disabled sms', () {
    final useCase = SendTestSms(sender: _FakeSmsSender());

    expect(() => useCase(const SharingSettings()), throwsStateError);
  });

  test('rejects missing sid', () {
    final useCase = SendTestSms(sender: _FakeSmsSender());

    expect(
      () => useCase(
        const SharingSettings(
          smsEnabled: true,
          smsAuthToken: 'token',
          smsFromNumber: '+15550000001',
          smsTestNumber: '+15550000002',
        ),
      ),
      throwsStateError,
    );
  });
}

class _FakeSmsSender implements SmsSender {
  SharingSettings? lastSettings;
  SmsMessage? lastMessage;

  @override
  Future<void> send({
    required SharingSettings settings,
    required SmsMessage message,
  }) async {
    lastSettings = settings;
    lastMessage = message;
  }
}
