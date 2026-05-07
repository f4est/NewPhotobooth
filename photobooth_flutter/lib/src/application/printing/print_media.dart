import '../../domain/photo/photo_collage.dart';
import '../../domain/printing/printer_repository.dart';
import '../../domain/settings/app_settings.dart';
import 'print_image_file.dart';

class PrintMedia {
  PrintMedia({required PrinterRepository repository})
    : _printImageFile = PrintImageFile(repository: repository);

  final PrintImageFile _printImageFile;

  Future<void> call({
    required PhotoCollage collage,
    required PrintSettings settings,
  }) async {
    await _printImageFile(filePath: collage.filePath, settings: settings);
  }
}
