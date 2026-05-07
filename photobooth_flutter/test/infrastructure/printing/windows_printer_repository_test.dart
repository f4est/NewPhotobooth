import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import 'package:photobooth_flutter/src/domain/printing/print_job.dart';
import 'package:photobooth_flutter/src/infrastructure/printing/windows_printer_repository.dart';

void main() {
  test('builds direct Windows PrintDocument command', () {
    const command = WindowsImagePrintCommand(
      PrintJob(
        filePath: r'C:\Events\collage.jpg',
        printerName: 'DNP RX1',
        paperName: '6 x 4 in',
        paperWidthInches: 6,
        paperHeightInches: 4,
      ),
    );

    expect(command.executable, 'powershell');
    expect(command.arguments, contains('-EncodedCommand'));
    expect(command.arguments, contains('-ExecutionPolicy'));
  });

  test('skips custom page settings when Windows settings are requested', () {
    const command = WindowsImagePrintCommand(
      PrintJob(
        filePath: r'C:\Events\collage.jpg',
        printerName: 'DNP RX1',
        useWindowsSettings: true,
      ),
    );

    final encoded = command.arguments.last;
    final script = _decodeUtf16Le(base64Decode(encoded));

    expect(script, contains(r'$doc.PrinterSettings.PrinterName'));
    expect(script, isNot(contains('DefaultPageSettings.PaperSize')));
    expect(script, isNot(contains('DefaultPageSettings.Margins')));
  });
}

String _decodeUtf16Le(List<int> bytes) {
  final units = <int>[];
  for (var index = 0; index < bytes.length; index += 2) {
    units.add(bytes[index] | (bytes[index + 1] << 8));
  }
  return String.fromCharCodes(units);
}
