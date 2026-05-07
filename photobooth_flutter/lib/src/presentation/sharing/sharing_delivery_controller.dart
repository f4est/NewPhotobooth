import 'package:flutter/foundation.dart';

import '../../application/sharing/send_media_email.dart';
import '../../application/sharing/send_media_sms.dart';
import '../../application/sharing/send_test_email.dart';
import '../../application/sharing/send_test_sms.dart';
import '../../application/sharing/save_media_to_pc.dart';
import '../../domain/settings/app_settings.dart';

class SharingDeliveryState {
  const SharingDeliveryState({
    this.isSendingMail = false,
    this.isSendingMedia = false,
    this.isSendingSms = false,
    this.isSavingMedia = false,
    this.message,
    this.errorMessage,
  });

  final bool isSendingMail;
  final bool isSendingMedia;
  final bool isSendingSms;
  final bool isSavingMedia;
  final String? message;
  final String? errorMessage;

  SharingDeliveryState copyWith({
    bool? isSendingMail,
    bool? isSendingMedia,
    bool? isSendingSms,
    bool? isSavingMedia,
    String? message,
    String? errorMessage,
  }) {
    return SharingDeliveryState(
      isSendingMail: isSendingMail ?? this.isSendingMail,
      isSendingMedia: isSendingMedia ?? this.isSendingMedia,
      isSendingSms: isSendingSms ?? this.isSendingSms,
      isSavingMedia: isSavingMedia ?? this.isSavingMedia,
      message: message,
      errorMessage: errorMessage,
    );
  }
}

class SharingDeliveryController extends ValueNotifier<SharingDeliveryState> {
  SharingDeliveryController({
    required SendTestEmail sendTestEmail,
    required SendMediaEmail sendMediaEmail,
    required SendMediaSms sendMediaSms,
    required SendTestSms sendTestSms,
    required SaveMediaToPc saveMediaToPc,
  }) : _sendTestEmail = sendTestEmail,
       _sendMediaEmail = sendMediaEmail,
       _sendMediaSms = sendMediaSms,
       _sendTestSms = sendTestSms,
       _saveMediaToPc = saveMediaToPc,
       super(const SharingDeliveryState());

  final SendTestEmail _sendTestEmail;
  final SendMediaEmail _sendMediaEmail;
  final SendMediaSms _sendMediaSms;
  final SendTestSms _sendTestSms;
  final SaveMediaToPc _saveMediaToPc;

  Future<void> sendTestEmail(SharingSettings settings) async {
    if (value.isSendingMail) {
      return;
    }

    value = value.copyWith(isSendingMail: true);
    try {
      await _sendTestEmail(settings);
      value = const SharingDeliveryState(message: 'Test email sent');
    } catch (error) {
      value = SharingDeliveryState(errorMessage: 'Test email failed: $error');
    }
  }

  Future<bool> sendMediaEmail({
    required SharingSettings settings,
    required String mediaFilePath,
    String? recipientEmail,
  }) async {
    if (value.isSendingMedia) {
      return false;
    }

    value = value.copyWith(isSendingMedia: true);
    try {
      await _sendMediaEmail(
        settings: settings,
        mediaFilePath: mediaFilePath,
        recipientEmail: recipientEmail,
      );
      value = const SharingDeliveryState(message: 'Media email sent');
      return true;
    } catch (error) {
      value = SharingDeliveryState(errorMessage: 'Email failed: $error');
      return false;
    }
  }

  Future<void> sendTestSms(SharingSettings settings) async {
    if (value.isSendingSms) {
      return;
    }

    value = value.copyWith(isSendingSms: true);
    try {
      await _sendTestSms(settings);
      value = const SharingDeliveryState(message: 'Test SMS sent');
    } catch (error) {
      value = SharingDeliveryState(errorMessage: 'Test SMS failed: $error');
    }
  }

  Future<bool> sendMediaSms({
    required SharingSettings settings,
    required Uri downloadUrl,
    String? recipientPhone,
  }) async {
    if (value.isSendingSms) {
      return false;
    }

    value = value.copyWith(isSendingSms: true);
    try {
      await _sendMediaSms(
        settings: settings,
        downloadUrl: downloadUrl,
        recipientPhone: recipientPhone,
      );
      value = const SharingDeliveryState(message: 'Media SMS sent');
      return true;
    } catch (error) {
      value = SharingDeliveryState(errorMessage: 'SMS failed: $error');
      return false;
    }
  }

  Future<bool> saveMediaToPc({
    required String sourcePath,
    required String destinationPath,
  }) async {
    if (value.isSavingMedia) {
      return false;
    }

    value = value.copyWith(isSavingMedia: true);
    try {
      final savedPath = await _saveMediaToPc(
        sourcePath: sourcePath,
        destinationPath: destinationPath,
      );
      value = SharingDeliveryState(message: 'Media saved: $savedPath');
      return true;
    } catch (error) {
      value = SharingDeliveryState(errorMessage: 'Save failed: $error');
      return false;
    }
  }

  void clear() {
    value = const SharingDeliveryState();
  }
}
