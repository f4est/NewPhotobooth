import '../../domain/settings/app_settings.dart';
import '../../domain/sharing/email_message.dart';
import '../../domain/sharing/email_sender.dart';

class SendTestEmail {
  const SendTestEmail({required EmailSender sender}) : _sender = sender;

  final EmailSender _sender;

  Future<void> call(SharingSettings settings) async {
    _validate(settings);

    await _sender.send(
      settings: settings,
      message: EmailMessage(
        from: settings.senderEmail.trim(),
        to: settings.receiverEmail.trim(),
        subject: settings.mailSubject.trim().isEmpty
            ? 'NewPhotobooth test email'
            : settings.mailSubject.trim(),
        body: settings.mailBody.trim().isEmpty
            ? 'This is a test email from NewPhotobooth.'
            : settings.mailBody.trim(),
      ),
    );
  }

  void _validate(SharingSettings settings) {
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
    if (settings.receiverEmail.trim().isEmpty) {
      throw StateError('Receiver email is required.');
    }
  }
}
