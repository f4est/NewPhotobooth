import 'qr_code_image.dart';

abstract interface class QrCodeGenerator {
  Future<QrCodeImage> generate({
    required String content,
    required String outputDirectory,
  });
}
