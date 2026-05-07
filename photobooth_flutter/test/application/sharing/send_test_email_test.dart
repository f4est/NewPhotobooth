import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/sharing/send_test_email.dart';
import 'package:photobooth_flutter/src/domain/settings/app_settings.dart';
import 'package:photobooth_flutter/src/domain/sharing/email_message.dart';
import 'package:photobooth_flutter/src/domain/sharing/email_sender.dart';

void main() {
  test('sends test email using SMTP settings', () async {
    final sender = _FakeEmailSender();
    final useCase = SendTestEmail(sender: sender);

    const settings = SharingSettings(
      mailEnabled: true,
      senderEmail: 'from@example.com',
      senderPassword: 'secret',
      smtpHost: 'smtp.example.com',
      receiverEmail: 'to@example.com',
      mailSubject: 'Subject',
      mailBody: 'Body',
    );

    await useCase(settings);

    expect(sender.lastSettings, settings);
    expect(sender.lastMessage?.from, 'from@example.com');
    expect(sender.lastMessage?.to, 'to@example.com');
    expect(sender.lastMessage?.subject, 'Subject');
    expect(sender.lastMessage?.body, 'Body');
  });

  test('rejects disabled mail', () {
    final useCase = SendTestEmail(sender: _FakeEmailSender());

    expect(() => useCase(const SharingSettings()), throwsStateError);
  });

  test('rejects incomplete smtp settings', () {
    final useCase = SendTestEmail(sender: _FakeEmailSender());

    expect(
      () => useCase(
        const SharingSettings(
          mailEnabled: true,
          senderEmail: 'from@example.com',
          senderPassword: 'secret',
          receiverEmail: 'to@example.com',
        ),
      ),
      throwsStateError,
    );
  });
}

class _FakeEmailSender implements EmailSender {
  SharingSettings? lastSettings;
  EmailMessage? lastMessage;

  @override
  Future<void> send({
    required SharingSettings settings,
    required EmailMessage message,
  }) async {
    lastSettings = settings;
    lastMessage = message;
  }
}
