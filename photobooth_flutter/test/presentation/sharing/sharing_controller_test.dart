import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/sharing/create_download_link.dart';
import 'package:photobooth_flutter/src/application/sharing/generate_qr_code.dart';
import 'package:photobooth_flutter/src/domain/sharing/download_link.dart';
import 'package:photobooth_flutter/src/domain/sharing/download_link_repository.dart';
import 'package:photobooth_flutter/src/domain/sharing/qr_code_generator.dart';
import 'package:photobooth_flutter/src/domain/sharing/qr_code_image.dart';
import 'package:photobooth_flutter/src/presentation/sharing/sharing_controller.dart';

void main() {
  test('creates link without qr when qr generation is disabled', () async {
    final qrGenerator = _FakeQrCodeGenerator();
    final controller = SharingController(
      createDownloadLink: CreateDownloadLink(repository: _FakeLinkRepository()),
      generateQrCode: GenerateQrCode(generator: qrGenerator),
    );

    await controller.createDownloadLink(
      'C:\\Event\\collage.jpg',
      generateQr: false,
    );

    expect(controller.value.downloadLink?.url.toString(), 'http://host/file');
    expect(controller.value.qrCode, isNull);
    expect(qrGenerator.calls, 0);
  });
}

class _FakeLinkRepository implements DownloadLinkRepository {
  @override
  Future<DownloadLink> createForFile(String filePath) async {
    return DownloadLink(filePath: filePath, url: Uri.parse('http://host/file'));
  }

  @override
  Future<void> dispose() async {}
}

class _FakeQrCodeGenerator implements QrCodeGenerator {
  var calls = 0;

  @override
  Future<QrCodeImage> generate({
    required String content,
    required String outputDirectory,
  }) async {
    calls += 1;
    return QrCodeImage(filePath: '$outputDirectory\\qr.png', content: content);
  }
}
