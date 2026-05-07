import 'dart:io';

import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';

import '../../domain/settings/app_settings.dart';
import '../../domain/sharing/email_message.dart';
import '../../domain/sharing/email_sender.dart';

class MailerEmailSender implements EmailSender {
  const MailerEmailSender();

  @override
  Future<void> send({
    required SharingSettings settings,
    required EmailMessage message,
  }) async {
    final server = SmtpServer(
      settings.smtpHost.trim(),
      port: settings.smtpPort,
      username: settings.senderEmail.trim(),
      password: settings.senderPassword,
      ssl: settings.smtpPort == 465,
      allowInsecure: false,
    );

    final mail = mailer.Message()
      ..from = mailer.Address(message.from)
      ..recipients.add(message.to)
      ..subject = message.subject
      ..text = message.body;

    final attachmentPath = message.attachmentPath;
    if (attachmentPath != null && attachmentPath.trim().isNotEmpty) {
      mail.attachments.add(mailer.FileAttachment(File(attachmentPath)));
    }

    await mailer.send(mail, server);
  }
}
