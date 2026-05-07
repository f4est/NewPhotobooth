import '../../domain/templates/image_template.dart';
import '../../domain/templates/template_repository.dart';

class SaveTemplates {
  const SaveTemplates({required TemplateRepository repository})
    : _repository = repository;

  final TemplateRepository _repository;

  Future<void> call(TemplateCatalog catalog) => _repository.save(catalog);
}
