import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/printing/print_test_page.dart';
import 'package:photobooth_flutter/src/domain/printing/print_job.dart';
import 'package:photobooth_flutter/src/domain/printing/printer_repository.dart';
import 'package:photobooth_flutter/src/domain/settings/app_settings.dart';

void main() {
  test('renders and prints a calibration page', () async {
    final temp = await Directory.systemTemp.createTemp('print-test-');
    final repository = _FakePrinterRepository();
    final useCase = PrintTestPage(repository: repository);

    final filePath = await useCase(
      outputDirectory: temp,
      settings: const PrintSettings(
        selectedPrinter: 'DNP RX1',
        paperSize: PrintPaperSize.fourBySix,
        silentPrint: false,
        offsetTop: 0.25,
      ),
    );

    expect(File(filePath).existsSync(), isTrue);
    expect(repository.lastJob?.filePath, filePath);
    expect(repository.lastJob?.printerName, 'DNP RX1');
    expect(repository.lastJob?.copies, 1);
    expect(repository.lastJob?.silentPrint, isFalse);
    expect(repository.lastJob?.paperName, '4 x 6 in');
    expect(repository.lastJob?.scaleMode, PrintJobScaleMode.fit);
    expect(repository.lastJob?.offsetTop, 0.25);

    await temp.delete(recursive: true);
  });

  test('rejects missing printer', () {
    final useCase = PrintTestPage(repository: _FakePrinterRepository());

    expect(() => useCase(settings: const PrintSettings()), throwsStateError);
  });
}

class _FakePrinterRepository implements PrinterRepository {
  PrintJob? lastJob;

  @override
  Future<List<String>> listPrinters() async => const ['DNP RX1'];

  @override
  Future<void> printImage(PrintJob job) async {
    lastJob = job;
  }
}
