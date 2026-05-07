import 'print_job.dart';

abstract interface class PrinterRepository {
  Future<List<String>> listPrinters();

  Future<void> printImage(PrintJob job);
}
