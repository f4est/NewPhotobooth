import '../../domain/templates/image_template.dart';
import '../../domain/templates/selected_template_repository.dart';
import '../../domain/templates/template_repository.dart';

class JsonSelectedTemplateRepository implements SelectedTemplateRepository {
  const JsonSelectedTemplateRepository({required TemplateRepository repository})
    : _repository = repository;

  final TemplateRepository _repository;

  @override
  Future<ImageTemplate> loadSelectedTemplate() async {
    final catalog = await _repository.load();
    return catalog.selectedTemplate;
  }
}
