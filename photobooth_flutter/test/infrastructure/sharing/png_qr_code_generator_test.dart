import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/infrastructure/sharing/png_qr_code_generator.dart';

void main() {
  test('generate writes a png qr code image', () async {
    final directory = await Directory.systemTemp.createTemp('qr_test');
    addTearDown(() => directory.delete(recursive: true));
    const generator = PngQrCodeGenerator(size: 256);

    final qr = await generator.generate(
      content: 'http://127.0.0.1/download/file.jpg',
      outputDirectory: directory.path,
    );

    final file = File(qr.filePath);
    expect(await file.exists(), isTrue);
    expect(qr.content, 'http://127.0.0.1/download/file.jpg');
    expect(await file.length(), greaterThan(1000));
  });
}
