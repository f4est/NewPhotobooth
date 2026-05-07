import 'image_template.dart';

abstract interface class SelectedTemplateRepository {
  Future<ImageTemplate> loadSelectedTemplate();
}
