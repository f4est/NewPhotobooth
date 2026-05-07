import 'dart:convert';
import 'dart:io';

import '../../domain/templates/image_template.dart';
import '../../domain/templates/template_repository.dart';
import 'template_catalog_json_mapper.dart';

class JsonFileTemplateRepository implements TemplateRepository {
  const JsonFileTemplateRepository({
    required File file,
    TemplateCatalogJsonMapper mapper = const TemplateCatalogJsonMapper(),
  }) : _file = file,
       _mapper = mapper;

  final File _file;
  final TemplateCatalogJsonMapper _mapper;

  @override
  Future<TemplateCatalog> load() async {
    if (!await _file.exists()) {
      return TemplateCatalog.initial();
    }

    final raw = await _file.readAsString();
    if (raw.trim().isEmpty) {
      return TemplateCatalog.initial();
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return TemplateCatalog.initial();
    }

    return _mapper.fromJson(decoded);
  }

  @override
  Future<void> save(TemplateCatalog catalog) async {
    await _file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await _file.writeAsString(encoder.convert(_mapper.toJson(catalog)));
  }
}

File defaultTemplatesFile() {
  final appData = Platform.environment['APPDATA'];
  final base = appData == null || appData.isEmpty
      ? Directory.current.path
      : appData;
  return File('$base\\NewPhotobooth\\templates.json');
}
