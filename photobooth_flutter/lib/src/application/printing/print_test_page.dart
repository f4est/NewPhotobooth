import 'dart:io';

import 'package:image/image.dart' as img;

import '../../domain/printing/print_job.dart';
import '../../domain/printing/printer_repository.dart';
import '../../domain/settings/app_settings.dart';

class PrintTestPage {
  const PrintTestPage({required PrinterRepository repository})
    : _repository = repository;

  final PrinterRepository _repository;

  Future<String> call({
    required PrintSettings settings,
    Directory? outputDirectory,
  }) async {
    if (!settings.enabled) {
      throw StateError('Printing is disabled in Print Settings.');
    }

    final printerName = settings.selectedPrinter.trim();
    if (printerName.isEmpty) {
      throw StateError('Select a printer before printing.');
    }

    final file = await _renderCalibrationPage(
      settings: settings,
      outputDirectory: outputDirectory ?? Directory.systemTemp,
    );

    await _repository.printImage(
      PrintJob(
        filePath: file.path,
        printerName: printerName,
        copies: 1,
        silentPrint: settings.silentPrint,
        paperName: settings.paperSize.label,
        paperWidthInches: settings.paperSize.widthInches,
        paperHeightInches: settings.paperSize.heightInches,
        scaleMode: PrintJobScaleMode.fit,
        useWindowsSettings: settings.useWindowsSettings,
        forceLandscape: settings.forceLandscape,
        forcePortrait: settings.forcePortrait,
        offsetTop: settings.offsetTop,
        offsetRight: settings.offsetRight,
        offsetBottom: settings.offsetBottom,
        offsetLeft: settings.offsetLeft,
      ),
    );

    return file.path;
  }

  Future<File> _renderCalibrationPage({
    required PrintSettings settings,
    required Directory outputDirectory,
  }) async {
    await outputDirectory.create(recursive: true);

    const dpi = 300;
    final width = (settings.paperSize.widthInches * dpi).round();
    final height = (settings.paperSize.heightInches * dpi).round();
    final canvas = img.Image(width: width, height: height);
    final white = img.ColorRgb8(255, 255, 255);
    final black = img.ColorRgb8(15, 23, 42);
    final red = img.ColorRgb8(220, 38, 38);
    final blue = img.ColorRgb8(37, 99, 235);
    final grey = img.ColorRgb8(203, 213, 225);

    img.fill(canvas, color: white);
    img.drawRect(
      canvas,
      x1: 24,
      y1: 24,
      x2: width - 25,
      y2: height - 25,
      color: black,
      thickness: 6,
    );
    img.drawRect(
      canvas,
      x1: (settings.offsetLeft * dpi).round().clamp(0, width - 1),
      y1: (settings.offsetTop * dpi).round().clamp(0, height - 1),
      x2: (width - (settings.offsetRight * dpi).round()).clamp(0, width - 1),
      y2: (height - (settings.offsetBottom * dpi).round()).clamp(0, height - 1),
      color: blue,
      thickness: 4,
    );
    img.drawLine(
      canvas,
      x1: width ~/ 2,
      y1: 24,
      x2: width ~/ 2,
      y2: height - 25,
      color: grey,
      thickness: 3,
    );
    img.drawLine(
      canvas,
      x1: 24,
      y1: height ~/ 2,
      x2: width - 25,
      y2: height ~/ 2,
      color: grey,
      thickness: 3,
    );
    img.drawCircle(
      canvas,
      x: width ~/ 2,
      y: height ~/ 2,
      radius: 32,
      color: red,
    );
    img.drawString(
      canvas,
      'NewPhotobooth print test',
      font: img.arial24,
      x: 48,
      y: 48,
      color: black,
    );
    img.drawString(
      canvas,
      '${settings.paperSize.label} | ${settings.scaleMode.name} | ${settings.silentPrint ? 'direct' : 'dialog'}',
      font: img.arial14,
      x: 48,
      y: 82,
      color: black,
    );
    img.drawString(
      canvas,
      'Blue rectangle shows configured print offsets.',
      font: img.arial14,
      x: 48,
      y: 108,
      color: black,
    );

    final file = File(
      '${outputDirectory.path}${Platform.pathSeparator}newphotobooth_print_test.png',
    );
    await file.writeAsBytes(img.encodePng(canvas), flush: true);
    return file;
  }
}
