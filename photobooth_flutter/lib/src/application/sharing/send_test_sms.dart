import '../../domain/settings/app_settings.dart';
import '../../domain/sharing/sms_message.dart';
import '../../domain/sharing/sms_sender.dart';

class SendTestSms {
  const SendTestSms({required SmsSender sender}) : _sender = sender;

  final SmsSender _sender;

  Future<void> call(SharingSettings settings) async {
    _validate(settings);

    await _sender.send(
      settings: settings,
      message: SmsMessage(
        from: settings.smsFromNumber.trim(),
        to: settings.smsTestNumber.trim(),
        body: 'This is a test SMS from NewPhotobooth.',
      ),
    );
  }

  void _validate(SharingSettings settings) {
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
    if (settings.smsTestNumber.trim().isEmpty) {
      throw StateError('SMS test phone number is required.');
    }
  }
}
