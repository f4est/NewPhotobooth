import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/printing/print_media.dart';
import 'package:photobooth_flutter/src/domain/photo/collage_layout.dart';
import 'package:photobooth_flutter/src/domain/photo/photo_collage.dart';
import 'package:photobooth_flutter/src/domain/printing/print_job.dart';
import 'package:photobooth_flutter/src/domain/printing/printer_repository.dart';
import 'package:photobooth_flutter/src/domain/settings/app_settings.dart';

void main() {
  test('prints collage with selected printer and configured copies', () async {
    final repository = _FakePrinterRepository();
    final useCase = PrintMedia(repository: repository);

    await useCase(
      collage: _collage(),
      settings: const PrintSettings(
        selectedPrinter: 'DNP RX1',
        printLimit: 2,
        paperSize: PrintPaperSize.fourBySix,
        scaleMode: PrintScaleMode.fit,
        forceLandscape: true,
        offsetTop: 1.5,
      ),
    );

    expect(repository.lastJob?.filePath, 'collage.jpg');
    expect(repository.lastJob?.printerName, 'DNP RX1');
    expect(repository.lastJob?.copies, 2);
    expect(repository.lastJob?.paperName, '4 x 6 in');
    expect(repository.lastJob?.paperWidthInches, 4);
    expect(repository.lastJob?.paperHeightInches, 6);
    expect(repository.lastJob?.scaleMode, PrintJobScaleMode.fit);
    expect(repository.lastJob?.useWindowsSettings, isFalse);
    expect(repository.lastJob?.forceLandscape, isTrue);
    expect(repository.lastJob?.offsetTop, 1.5);
  });

  test('passes Windows printer settings mode to the print job', () async {
    final repository = _FakePrinterRepository();
    final useCase = PrintMedia(repository: repository);

    await useCase(
      collage: _collage(),
      settings: const PrintSettings(
        selectedPrinter: 'DNP RX1',
        useWindowsSettings: true,
      ),
    );

    expect(repository.lastJob?.useWindowsSettings, isTrue);
  });

  test('rejects disabled printing', () {
    final useCase = PrintMedia(repository: _FakePrinterRepository());

    expect(
      () => useCase(
        collage: _collage(),
        settings: const PrintSettings(enabled: false),
      ),
      throwsStateError,
    );
  });

  test('rejects missing selected printer', () {
    final useCase = PrintMedia(repository: _FakePrinterRepository());

    expect(
      () => useCase(collage: _collage(), settings: const PrintSettings()),
      throwsStateError,
    );
  });
}

PhotoCollage _collage() {
  return PhotoCollage(
    id: 'collage-1',
    filePath: 'collage.jpg',
    sourcePhotos: const [],
    layout: CollageLayout.grid(photoCount: 1),
    createdAt: DateTime(2026, 5, 6),
  );
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
