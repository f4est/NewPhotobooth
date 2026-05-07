import '../settings/app_settings.dart';
import 'email_message.dart';

abstract interface class EmailSender {
  Future<void> send({
    required SharingSettings settings,
    required EmailMessage message,
  });
}
