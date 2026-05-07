import 'image_template.dart';

abstract interface class TemplateRepository {
  Future<TemplateCatalog> load();

  Future<void> save(TemplateCatalog catalog);
}
