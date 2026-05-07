import '../../domain/settings/app_settings.dart';
import '../../domain/sharing/email_message.dart';
import '../../domain/sharing/email_sender.dart';

class SendMediaEmail {
  const SendMediaEmail({required EmailSender sender}) : _sender = sender;

  final EmailSender _sender;

  Future<void> call({
    required SharingSettings settings,
    required String mediaFilePath,
    String? recipientEmail,
  }) async {
    final recipient = recipientEmail?.trim().isNotEmpty ?? false
        ? recipientEmail!.trim()
        : settings.receiverEmail.trim();
    _validate(settings, recipient);

    await _sender.send(
      settings: settings,
      message: EmailMessage(
        from: settings.senderEmail.trim(),
        to: recipient,
        subject: settings.mailSubject.trim().isEmpty
            ? 'Your photobooth media'
            : settings.mailSubject.trim(),
        body: settings.mailBody.trim().isEmpty
            ? 'Your photobooth media is attached.'
            : settings.mailBody.trim(),
        attachmentPath: mediaFilePath,
      ),
    );
  }

  void _validate(SharingSettings settings, String recipient) {
    if (!settings.mailEnabled) {
      throw StateError('Mail sharing is disabled.');
    }
    if (settings.senderEmail.trim().isEmpty) {
      throw StateError('Sender email is required.');
    }
    if (settings.senderPassword.trim().isEmpty) {
      throw StateError('Sender password is required.');
    }
    if (settings.smtpHost.trim().isEmpty) {
      throw StateError('SMTP host is required.');
    }
    if (recipient.isEmpty) {
      throw StateError('Receiver email is required.');
    }
  }
}
