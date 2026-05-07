import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:qr/qr.dart';

import '../../domain/sharing/qr_code_generator.dart';
import '../../domain/sharing/qr_code_image.dart';

class PngQrCodeGenerator implements QrCodeGenerator {
  const PngQrCodeGenerator({this.size = 512, this.quietZoneModules = 4});

  final int size;
  final int quietZoneModules;

  @override
  Future<QrCodeImage> generate({
    required String content,
    required String outputDirectory,
  }) async {
    final directory = Directory(outputDirectory);
    await directory.create(recursive: true);

    final qr = QrCode.fromData(
      data: content,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    final image = _render(QrImage(qr));
    final file = File(
      '${directory.path}\\qr_${DateTime.now().microsecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(img.encodePng(image), flush: true);

    return QrCodeImage(filePath: file.path, content: content);
  }

  img.Image _render(QrImage qr) {
    final modules = qr.moduleCount + quietZoneModules * 2;
    final pixelsPerModule = (size / modules).floor().clamp(1, size);
    final imageSize = modules * pixelsPerModule;
    final image = img.Image(width: imageSize, height: imageSize);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));

    for (var y = 0; y < qr.moduleCount; y += 1) {
      for (var x = 0; x < qr.moduleCount; x += 1) {
        if (!qr.isDark(y, x)) {
          continue;
        }

        final left = (x + quietZoneModules) * pixelsPerModule;
        final top = (y + quietZoneModules) * pixelsPerModule;
        img.fillRect(
          image,
          x1: left,
          y1: top,
          x2: left + pixelsPerModule - 1,
          y2: top + pixelsPerModule - 1,
          color: img.ColorRgb8(0, 0, 0),
        );
      }
    }

    return image;
  }
}
