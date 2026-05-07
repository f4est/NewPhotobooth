import 'package:flutter/material.dart';

import '../../../domain/settings/app_settings.dart';
import '../../printing/media_print_controller.dart';
import '../../printing/printer_controller.dart';
import '../../settings/settings_controller.dart';
import '../shell_chrome.dart';

class PrintSettingsPage extends StatelessWidget {
  const PrintSettingsPage({
    required this.controller,
    required this.printerController,
    required this.mediaPrintController,
    super.key,
  });

  final SettingsController controller;
  final PrinterController printerController;
  final MediaPrintController mediaPrintController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SettingsState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final settings = state.settings;
        final print = settings.print;

        return AdminPage(
          title: 'Print Settings',
          subtitle:
              'Configure direct Windows printing, photo paper sizes and output positioning.',
          children: [
            AdminPanel(
              title: 'Print Options',
              child: Wrap(
                spacing: 40,
                children: [
                  OptionSwitch(
                    label: 'Print',
                    value: print.enabled,
                    onChanged: (value) =>
                        _update(settings, print.copyWith(enabled: value)),
                  ),
                  OptionSwitch(
                    label: 'Direct Print',
                    value: print.silentPrint,
                    onChanged: (value) =>
                        _update(settings, print.copyWith(silentPrint: value)),
                  ),
                  OptionSwitch(
                    label: 'One Print Per Photo',
                    value: print.onePrintPerPhoto,
                    onChanged: (value) => _update(
                      settings,
                      print.copyWith(onePrintPerPhoto: value),
                    ),
                  ),
                  OptionSwitch(
                    label: 'Use Windows Settings',
                    value: print.useWindowsSettings,
                    onChanged: (value) => _update(
                      settings,
                      print.copyWith(useWindowsSettings: value),
                    ),
                  ),
                  OptionSwitch(
                    label: 'Force Landscape',
                    value: print.forceLandscape,
                    onChanged: (value) => _update(
                      settings,
                      print.copyWith(
                        forceLandscape: value,
                        forcePortrait: value ? false : print.forcePortrait,
                      ),
                    ),
                  ),
                  OptionSwitch(
                    label: 'Force Portrait',
                    value: print.forcePortrait,
                    onChanged: (value) => _update(
                      settings,
                      print.copyWith(
                        forcePortrait: value,
                        forceLandscape: value ? false : print.forceLandscape,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ValueListenableBuilder<MediaPrintState>(
              valueListenable: mediaPrintController,
              builder: (context, printState, _) {
                return AdminPanel(
                  title: 'Printer',
                  child: SizedBox(
                    height: 500,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 360,
                              child: _PrinterSelector(
                                selectedPrinter: print.selectedPrinter,
                                printerController: printerController,
                                onChanged: (printer) => _update(
                                  settings,
                                  print.copyWith(
                                    selectedPrinter: printer ?? '',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                            SizedBox(
                              width: 180,
                              child: _PaperSizeSelector(
                                paperSize: print.paperSize,
                                onChanged: (paperSize) => _update(
                                  settings,
                                  print.copyWith(paperSize: paperSize),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            SizedBox(
                              width: 150,
                              child: _ScaleModeSelector(
                                scaleMode: print.scaleMode,
                                onChanged: (scaleMode) => _update(
                                  settings,
                                  print.copyWith(scaleMode: scaleMode),
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            SizedBox(
                              width: 100,
                              child: _Field(
                                label: 'Print Limit',
                                value: print.printLimit.toString(),
                                keyboardType: TextInputType.number,
                                onChanged: (value) => _update(
                                  settings,
                                  print.copyWith(
                                    printLimit:
                                        int.tryParse(value) ?? print.printLimit,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            OutlinedButton.icon(
                              onPressed: printerController.refresh,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed:
                                  printState.isPrinting ||
                                      !print.enabled ||
                                      print.selectedPrinter.trim().isEmpty
                                  ? null
                                  : () => mediaPrintController.printTestPage(
                                      settings: print,
                                    ),
                              icon: printState.isPrinting
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.fact_check_outlined),
                              label: const Text('Test Print'),
                            ),
                          ],
                        ),
                        if (printState.message != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(printState.message!),
                          ),
                        ],
                        if (printState.errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              printState.errorMessage!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Selected size: ${print.paperSize.label} (${print.paperSize.widthInches.toStringAsFixed(2)} x ${print.paperSize.heightInches.toStringAsFixed(2)} in). Direct Print sends the image immediately to the selected printer without a dialog.',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: _PrintOffsetEditor(
                            settings: settings,
                            controller: controller,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _update(AppSettings settings, PrintSettings print) {
    controller.update(settings.copyWith(print: print));
  }
}

class _PaperSizeSelector extends StatelessWidget {
  const _PaperSizeSelector({required this.paperSize, required this.onChanged});

  final PrintPaperSize paperSize;
  final ValueChanged<PrintPaperSize> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormFieldLabel('Photo Size'),
        DropdownButtonFormField<PrintPaperSize>(
          initialValue: paperSize,
          items: [
            for (final size in PrintPaperSize.values)
              DropdownMenuItem(value: size, child: Text(size.label)),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}

class _ScaleModeSelector extends StatelessWidget {
  const _ScaleModeSelector({required this.scaleMode, required this.onChanged});

  final PrintScaleMode scaleMode;
  final ValueChanged<PrintScaleMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormFieldLabel('Image Fit'),
        DropdownButtonFormField<PrintScaleMode>(
          initialValue: scaleMode,
          items: const [
            DropdownMenuItem(value: PrintScaleMode.fill, child: Text('Fill')),
            DropdownMenuItem(value: PrintScaleMode.fit, child: Text('Fit')),
          ],
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}

class _PrinterSelector extends StatelessWidget {
  const _PrinterSelector({
    required this.selectedPrinter,
    required this.printerController,
    required this.onChanged,
  });

  final String selectedPrinter;
  final PrinterController printerController;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PrinterState>(
      valueListenable: printerController,
      builder: (context, state, _) {
        final printers = state.printers;
        final selected = printers.contains(selectedPrinter)
            ? selectedPrinter
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormFieldLabel('Select Printer'),
            DropdownButtonFormField<String>(
              initialValue: selected,
              hint: Text(
                state.isLoading ? 'Loading printers...' : 'No printer selected',
              ),
              items: [
                for (final printer in printers)
                  DropdownMenuItem(value: printer, child: Text(printer)),
              ],
              onChanged: onChanged,
            ),
            if (!state.isLoading && printers.isEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'No Windows printers found.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _PrintOffsetEditor extends StatelessWidget {
  const _PrintOffsetEditor({required this.settings, required this.controller});

  final AppSettings settings;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final print = settings.print;

    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 100,
              child: _Field(
                label: 'Top',
                value: print.offsetTop.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                onChanged: (value) => _update(
                  print.copyWith(
                    offsetTop: double.tryParse(value) ?? print.offsetTop,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: _Field(
                  label: 'Left',
                  value: print.offsetLeft.toStringAsFixed(2),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _update(
                    print.copyWith(
                      offsetLeft: double.tryParse(value) ?? print.offsetLeft,
                    ),
                  ),
                ),
              ),
              const Expanded(child: _PrintOffsetPreview()),
              SizedBox(
                width: 100,
                child: _Field(
                  label: 'Right',
                  value: print.offsetRight.toStringAsFixed(2),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _update(
                    print.copyWith(
                      offsetRight: double.tryParse(value) ?? print.offsetRight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Spacer(),
            SizedBox(
              width: 100,
              child: _Field(
                label: 'Bottom',
                value: print.offsetBottom.toStringAsFixed(2),
                keyboardType: TextInputType.number,
                onChanged: (value) => _update(
                  print.copyWith(
                    offsetBottom: double.tryParse(value) ?? print.offsetBottom,
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  void _update(PrintSettings print) {
    controller.update(settings.copyWith(print: print));
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final String value;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label),
        CompactInput(
          initialValue: value,
          keyboardType: keyboardType,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PrintOffsetPreview extends StatelessWidget {
  const _PrintOffsetPreview();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PrintOffsetPainter(),
      child: const Center(
        child: SizedBox(
          width: 230,
          height: 130,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xffeeeeee),
              border: Border.fromBorderSide(BorderSide()),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrintOffsetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xffd1d5db)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
