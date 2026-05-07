import '../../domain/sharing/qr_code_generator.dart';
import '../../domain/sharing/qr_code_image.dart';

class GenerateQrCode {
  const GenerateQrCode({required QrCodeGenerator generator})
    : _generator = generator;

  final QrCodeGenerator _generator;

  Future<QrCodeImage> call({
    required String content,
    required String outputDirectory,
  }) {
    return _generator.generate(
      content: content,
      outputDirectory: outputDirectory,
    );
  }
}
