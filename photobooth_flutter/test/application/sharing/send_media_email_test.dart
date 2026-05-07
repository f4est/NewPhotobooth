import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/sharing/send_media_email.dart';
import 'package:photobooth_flutter/src/domain/settings/app_settings.dart';
import 'package:photobooth_flutter/src/domain/sharing/email_message.dart';
import 'package:photobooth_flutter/src/domain/sharing/email_sender.dart';

void main() {
  test('sends media email with attachment path', () async {
    final sender = _FakeEmailSender();
    final useCase = SendMediaEmail(sender: sender);

    const settings = SharingSettings(
      mailEnabled: true,
      senderEmail: 'from@example.com',
      senderPassword: 'secret',
      smtpHost: 'smtp.example.com',
      receiverEmail: 'to@example.com',
      mailSubject: 'Your photo',
      mailBody: 'Attached',
    );

    await useCase(settings: settings, mediaFilePath: 'collage.jpg');

    expect(sender.lastMessage?.to, 'to@example.com');
    expect(sender.lastMessage?.attachmentPath, 'collage.jpg');
    expect(sender.lastMessage?.subject, 'Your photo');
    expect(sender.lastMessage?.body, 'Attached');
  });

  test('sends media email to entered guest recipient', () async {
    final sender = _FakeEmailSender();
    final useCase = SendMediaEmail(sender: sender);

    const settings = SharingSettings(
      mailEnabled: true,
      senderEmail: 'from@example.com',
      senderPassword: 'secret',
      smtpHost: 'smtp.example.com',
      receiverEmail: 'admin@example.com',
    );

    await useCase(
      settings: settings,
      mediaFilePath: 'collage.jpg',
      recipientEmail: 'guest@example.com',
    );

    expect(sender.lastMessage?.to, 'guest@example.com');
  });

  test('rejects missing receiver', () {
    final useCase = SendMediaEmail(sender: _FakeEmailSender());

    expect(
      () => useCase(
        settings: const SharingSettings(
          mailEnabled: true,
          senderEmail: 'from@example.com',
          senderPassword: 'secret',
          smtpHost: 'smtp.example.com',
        ),
        mediaFilePath: 'collage.jpg',
      ),
      throwsStateError,
    );
  });
}

class _FakeEmailSender implements EmailSender {
  EmailMessage? lastMessage;

  @override
  Future<void> send({
    required SharingSettings settings,
    required EmailMessage message,
  }) async {
    lastMessage = message;
  }
}
