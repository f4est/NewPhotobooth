import '../../domain/settings/app_settings.dart';
import '../../domain/sharing/sms_message.dart';
import '../../domain/sharing/sms_sender.dart';

class SendMediaSms {
  const SendMediaSms({required SmsSender sender}) : _sender = sender;

  final SmsSender _sender;

  Future<void> call({
    required SharingSettings settings,
    required Uri downloadUrl,
    String? recipientPhone,
  }) async {
    final recipient = recipientPhone?.trim().isNotEmpty ?? false
        ? recipientPhone!.trim()
        : settings.smsTestNumber.trim();
    _validate(settings, recipient);

    await _sender.send(
      settings: settings,
      message: SmsMessage(
        from: settings.smsFromNumber.trim(),
        to: recipient,
        body: 'Your photobooth media: $downloadUrl',
      ),
    );
  }

  void _validate(SharingSettings settings, String recipient) {
    if (!settings.smsEnabled) {
      throw StateError('SMS sharing is disabled.');
    }
    if (settings.smsSid.trim().isEmpty) {
      throw StateError('SMS SID is required.');
    }
    if (settings.smsAuthToken.trim().isEmpty) {
      throw StateError('SMS auth token is required.');
    }
    if (settings.smsFromNumber.trim().isEmpty) {
      throw StateError('SMS host phone number is required.');
    }
    if (recipient.isEmpty) {
      throw StateError('SMS receiver phone number is required.');
    }
  }
}
