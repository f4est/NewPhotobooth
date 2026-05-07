import '../../domain/templates/image_template.dart';
import '../../domain/templates/template_repository.dart';

class LoadTemplates {
  const LoadTemplates({required TemplateRepository repository})
    : _repository = repository;

  final TemplateRepository _repository;

  Future<TemplateCatalog> call() => _repository.load();
}
