import 'package:flutter/foundation.dart';

import '../../application/printing/list_printers.dart';

class PrinterState {
  const PrinterState({this.printers = const [], this.isLoading = false});

  final List<String> printers;
  final bool isLoading;
}

class PrinterController extends ValueNotifier<PrinterState> {
  PrinterController({required ListPrinters listPrinters})
    : _listPrinters = listPrinters,
      super(const PrinterState());

  final ListPrinters _listPrinters;

  Future<void> refresh() async {
    value = const PrinterState(isLoading: true);
    final printers = await _listPrinters();
    value = PrinterState(printers: printers);
  }
}
