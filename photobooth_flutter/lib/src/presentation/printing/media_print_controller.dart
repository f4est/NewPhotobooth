import 'package:flutter/foundation.dart';

import '../../application/printing/print_image_file.dart';
import '../../application/printing/print_media.dart';
import '../../application/printing/print_test_page.dart';
import '../../domain/photo/photo_collage.dart';
import '../../domain/settings/app_settings.dart';

class MediaPrintState {
  const MediaPrintState({
    this.isPrinting = false,
    this.printedCount = 0,
    this.message,
    this.errorMessage,
  });

  final bool isPrinting;
  final int printedCount;
  final String? message;
  final String? errorMessage;

  MediaPrintState copyWith({
    bool? isPrinting,
    int? printedCount,
    String? message,
    String? errorMessage,
  }) {
    return MediaPrintState(
      isPrinting: isPrinting ?? this.isPrinting,
      printedCount: printedCount ?? this.printedCount,
      message: message,
      errorMessage: errorMessage,
    );
  }
}

class MediaPrintController extends ValueNotifier<MediaPrintState> {
  MediaPrintController({
    required PrintMedia printMedia,
    required PrintImageFile printImageFile,
    required PrintTestPage printTestPage,
  }) : _printMedia = printMedia,
       _printImageFile = printImageFile,
       _printTestPage = printTestPage,
       super(const MediaPrintState());

  final PrintMedia _printMedia;
  final PrintImageFile _printImageFile;
  final PrintTestPage _printTestPage;

  Future<bool> printCollage({
    required PhotoCollage collage,
    required PrintSettings settings,
  }) async {
    if (value.isPrinting) {
      return false;
    }

    value = value.copyWith(isPrinting: true);

    try {
      await _printMedia(collage: collage, settings: settings);
      value = value.copyWith(
        isPrinting: false,
        printedCount: value.printedCount + 1,
        message: 'Sent to printer',
      );
      return true;
    } catch (error) {
      value = value.copyWith(
        isPrinting: false,
        errorMessage: 'Print failed: $error',
      );
      return false;
    }
  }

  Future<bool> printFile({
    required String filePath,
    required PrintSettings settings,
  }) async {
    if (value.isPrinting) {
      return false;
    }

    value = value.copyWith(isPrinting: true);

    try {
      await _printImageFile(filePath: filePath, settings: settings);
      value = value.copyWith(
        isPrinting: false,
        printedCount: value.printedCount + 1,
        message: 'Sent to printer',
      );
      return true;
    } catch (error) {
      value = value.copyWith(
        isPrinting: false,
        errorMessage: 'Print failed: $error',
      );
      return false;
    }
  }

  Future<bool> printTestPage({required PrintSettings settings}) async {
    if (value.isPrinting) {
      return false;
    }

    value = value.copyWith(isPrinting: true);

    try {
      final filePath = await _printTestPage(settings: settings);
      value = value.copyWith(
        isPrinting: false,
        printedCount: value.printedCount + 1,
        message: 'Test page sent to printer: $filePath',
      );
      return true;
    } catch (error) {
      value = value.copyWith(
        isPrinting: false,
        errorMessage: 'Test print failed: $error',
      );
      return false;
    }
  }

  void clear() {
    value = const MediaPrintState();
  }
}
