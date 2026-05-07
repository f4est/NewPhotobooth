import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/sharing/send_media_sms.dart';
import 'package:photobooth_flutter/src/domain/settings/app_settings.dart';
import 'package:photobooth_flutter/src/domain/sharing/sms_message.dart';
import 'package:photobooth_flutter/src/domain/sharing/sms_sender.dart';

void main() {
  test('sends media sms with download url', () async {
    final sender = _FakeSmsSender();
    final useCase = SendMediaSms(sender: sender);

    const settings = SharingSettings(
      smsEnabled: true,
      smsSid: 'AC123',
      smsAuthToken: 'token',
      smsFromNumber: '+15550000001',
      smsTestNumber: '+15550000002',
    );

    await useCase(
      settings: settings,
      downloadUrl: Uri.parse('http://localhost:8080/collage.jpg'),
    );

    expect(sender.lastMessage?.from, '+15550000001');
    expect(sender.lastMessage?.to, '+15550000002');
    expect(sender.lastMessage?.body, contains('http://localhost:8080'));
  });

  test('sends media sms to entered guest phone', () async {
    final sender = _FakeSmsSender();
    final useCase = SendMediaSms(sender: sender);

    const settings = SharingSettings(
      smsEnabled: true,
      smsSid: 'AC123',
      smsAuthToken: 'token',
      smsFromNumber: '+15550000001',
      smsTestNumber: '+15550000002',
    );

    await useCase(
      settings: settings,
      downloadUrl: Uri.parse('http://localhost:8080/collage.jpg'),
      recipientPhone: '+15550000003',
    );

    expect(sender.lastMessage?.to, '+15550000003');
  });

  test('rejects disabled sms', () {
    final useCase = SendMediaSms(sender: _FakeSmsSender());

    expect(
      () => useCase(
        settings: const SharingSettings(),
        downloadUrl: Uri.parse('http://localhost'),
      ),
      throwsStateError,
    );
  });
}

class _FakeSmsSender implements SmsSender {
  SmsMessage? lastMessage;

  @override
  Future<void> send({
    required SharingSettings settings,
    required SmsMessage message,
  }) async {
    lastMessage = message;
  }
}
