import '../settings/app_settings.dart';
import 'sms_message.dart';

abstract interface class SmsSender {
  Future<void> send({
    required SharingSettings settings,
    required SmsMessage message,
  });
}
