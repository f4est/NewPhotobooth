import '../../domain/printing/print_job.dart';
import '../../domain/printing/printer_repository.dart';
import '../../domain/settings/app_settings.dart';

class PrintImageFile {
  const PrintImageFile({required PrinterRepository repository})
    : _repository = repository;

  final PrinterRepository _repository;

  Future<void> call({
    required String filePath,
    required PrintSettings settings,
  }) async {
    if (!settings.enabled) {
      throw StateError('Printing is disabled in Print Settings.');
    }

    final printerName = settings.selectedPrinter.trim();
    if (printerName.isEmpty) {
      throw StateError('Select a printer before printing.');
    }

    await _repository.printImage(
      PrintJob(
        filePath: filePath,
        printerName: printerName,
        copies: settings.printLimit <= 0 ? 1 : settings.printLimit,
        silentPrint: settings.silentPrint,
        paperName: settings.paperSize.label,
        paperWidthInches: settings.paperSize.widthInches,
        paperHeightInches: settings.paperSize.heightInches,
        scaleMode: settings.scaleMode == PrintScaleMode.fill
            ? PrintJobScaleMode.fill
            : PrintJobScaleMode.fit,
        useWindowsSettings: settings.useWindowsSettings,
        forceLandscape: settings.forceLandscape,
        forcePortrait: settings.forcePortrait,
        offsetTop: settings.offsetTop,
        offsetRight: settings.offsetRight,
        offsetBottom: settings.offsetBottom,
        offsetLeft: settings.offsetLeft,
      ),
    );
  }
}
