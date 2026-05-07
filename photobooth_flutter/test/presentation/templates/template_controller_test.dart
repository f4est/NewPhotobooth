import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/templates/load_templates.dart';
import 'package:photobooth_flutter/src/application/templates/save_templates.dart';
import 'package:photobooth_flutter/src/domain/templates/image_template.dart';
import 'package:photobooth_flutter/src/domain/templates/template_repository.dart';
import 'package:photobooth_flutter/src/presentation/templates/template_controller.dart';

void main() {
  test('clamps slot updates inside selected template bounds', () async {
    final repository = _FakeTemplateRepository(
      TemplateCatalog(
        selectedTemplateId: 'template',
        templates: [
          ImageTemplate(
            id: 'template',
            name: 'Template',
            outputWidth: 1200,
            outputHeight: 1800,
            photoSlots: [
              TemplatePhotoSlot(x: 100, y: 100, width: 400, height: 400),
            ],
          ),
        ],
      ),
    );
    final controller = TemplateController(
      loadTemplates: LoadTemplates(repository: repository),
      saveTemplates: SaveTemplates(repository: repository),
    );
    await controller.load();

    await controller.updateSlot(
      0,
      const TemplatePhotoSlot(x: -50, y: 1900, width: 1400, height: 50),
    );

    final slot = controller.value.catalog.selectedTemplate.photoSlots.single;
    expect(slot.x, 0);
    expect(slot.y, 1750);
    expect(slot.width, 1200);
    expect(slot.height, 50);
  });
}

class _FakeTemplateRepository implements TemplateRepository {
  _FakeTemplateRepository(this.catalog);

  TemplateCatalog catalog;

  @override
  Future<TemplateCatalog> load() async => catalog;

  @override
  Future<void> save(TemplateCatalog catalog) async {
    this.catalog = catalog;
  }
}
