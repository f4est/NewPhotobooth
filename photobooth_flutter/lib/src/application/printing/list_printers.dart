import '../../domain/printing/printer_repository.dart';

class ListPrinters {
  const ListPrinters({required PrinterRepository repository})
    : _repository = repository;

  final PrinterRepository _repository;

  Future<List<String>> call() => _repository.listPrinters();
}
