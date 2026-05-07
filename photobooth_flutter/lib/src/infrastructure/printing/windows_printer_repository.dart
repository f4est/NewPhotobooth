import 'dart:convert';
import 'dart:io';

import '../../domain/printing/print_job.dart';
import '../../domain/printing/printer_repository.dart';

typedef ProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

class WindowsPrinterRepository implements PrinterRepository {
  WindowsPrinterRepository({ProcessRunner? processRunner})
    : _processRunner = processRunner ?? Process.run;

  final ProcessRunner _processRunner;

  @override
  Future<List<String>> listPrinters() async {
    if (!Platform.isWindows) {
      return const [];
    }

    final result = await _processRunner('powershell', [
      '-NoProfile',
      '-Command',
      'Get-Printer | Select-Object -ExpandProperty Name | ConvertTo-Json',
    ]);

    if (result.exitCode != 0) {
      return const [];
    }

    final output = result.stdout.toString().trim();
    if (output.isEmpty) {
      return const [];
    }

    final decoded = jsonDecode(output);
    if (decoded is String) {
      return [decoded];
    }
    if (decoded is List) {
      return decoded.whereType<String>().toList(growable: false);
    }
    return const [];
  }

  @override
  Future<void> printImage(PrintJob job) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('Windows printing is available only on Windows.');
    }

    final file = File(job.filePath);
    if (!await file.exists()) {
      throw StateError('Print file does not exist: ${job.filePath}');
    }

    for (var copy = 0; copy < job.copies; copy += 1) {
      final command = WindowsImagePrintCommand(job);
      final result = await _processRunner(
        command.executable,
        command.arguments,
      );
      if (result.exitCode != 0) {
        throw StateError(
          'Printer command failed (${result.exitCode}): ${result.stderr}',
        );
      }
    }
  }
}

class WindowsImagePrintCommand {
  const WindowsImagePrintCommand(this.job);

  final PrintJob job;

  String get executable => 'powershell';

  List<String> get arguments => [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-EncodedCommand',
    base64Encode(utf16le.encode(_script)),
  ];

  String get _script {
    final landscape = job.forceLandscape
        ? true
        : job.forcePortrait
        ? false
        : job.paperWidthInches > job.paperHeightInches;
    final paperWidth = _hundredthsOfInch(job.paperWidthInches);
    final paperHeight = _hundredthsOfInch(job.paperHeightInches);
    final top = _hundredthsOfInch(job.offsetTop);
    final right = _hundredthsOfInch(job.offsetRight);
    final bottom = _hundredthsOfInch(job.offsetBottom);
    final left = _hundredthsOfInch(job.offsetLeft);
    final mode = job.scaleMode == PrintJobScaleMode.fill ? 'fill' : 'fit';
    final pageSettingsScript = job.useWindowsSettings
        ? ''
        : '''
\$doc.DefaultPageSettings.Landscape = \$${landscape ? 'true' : 'false'}
\$doc.DefaultPageSettings.PaperSize = New-Object System.Drawing.Printing.PaperSize('${_ps(job.paperName)}', $paperWidth, $paperHeight)
\$doc.DefaultPageSettings.Margins = New-Object System.Drawing.Printing.Margins($left, $right, $top, $bottom)
''';
    final printDialogScript = job.silentPrint
        ? ''
        : '''
Add-Type -AssemblyName System.Windows.Forms
\$dialog = New-Object System.Windows.Forms.PrintDialog
\$dialog.Document = \$doc
\$dialog.AllowSomePages = \$false
\$dialog.AllowSelection = \$false
\$dialog.UseEXDialog = \$true
\$dialogResult = \$dialog.ShowDialog()
if (\$dialogResult -ne [System.Windows.Forms.DialogResult]::OK) {
  \$doc.Dispose()
  exit 0
}
''';

    return '''
Add-Type -AssemblyName System.Drawing
\$imagePath = '${_ps(job.filePath)}'
\$printerName = '${_ps(job.printerName)}'
\$doc = New-Object System.Drawing.Printing.PrintDocument
\$doc.PrinterSettings.PrinterName = \$printerName
$pageSettingsScript
$printDialogScript
\$doc.add_PrintPage({
  param(\$sender, \$e)
  \$img = [System.Drawing.Image]::FromFile(\$imagePath)
  try {
    \$bounds = \$e.MarginBounds
    \$scaleX = \$bounds.Width / \$img.Width
    \$scaleY = \$bounds.Height / \$img.Height
    \$scale = if ('$mode' -eq 'fill') { [Math]::Max(\$scaleX, \$scaleY) } else { [Math]::Min(\$scaleX, \$scaleY) }
    \$width = [int](\$img.Width * \$scale)
    \$height = [int](\$img.Height * \$scale)
    \$x = [int](\$bounds.Left + ((\$bounds.Width - \$width) / 2))
    \$y = [int](\$bounds.Top + ((\$bounds.Height - \$height) / 2))
    \$dest = New-Object System.Drawing.Rectangle(\$x, \$y, \$width, \$height)
    \$e.Graphics.DrawImage(\$img, \$dest)
    \$e.HasMorePages = \$false
  } finally {
    \$img.Dispose()
  }
})
\$doc.Print()
\$doc.Dispose()
''';
  }

  int _hundredthsOfInch(double inches) => (inches * 100).round();

  String _ps(String value) => value.replaceAll("'", "''");
}

class _Utf16LeCodec extends Encoding {
  const _Utf16LeCodec();

  @override
  Converter<List<int>, String> get decoder => throw UnimplementedError();

  @override
  Converter<String, List<int>> get encoder => const _Utf16LeEncoder();

  @override
  String get name => 'utf-16le';
}

class _Utf16LeEncoder extends Converter<String, List<int>> {
  const _Utf16LeEncoder();

  @override
  List<int> convert(String input) {
    final bytes = <int>[];
    for (final codeUnit in input.codeUnits) {
      bytes.add(codeUnit & 0xff);
      bytes.add((codeUnit >> 8) & 0xff);
    }
    return bytes;
  }
}

const utf16le = _Utf16LeCodec();
