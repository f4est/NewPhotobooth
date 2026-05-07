import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/domain/templates/image_template.dart';
import 'package:photobooth_flutter/src/infrastructure/templates/json_file_template_repository.dart';

void main() {
  test('load returns default catalog when file is missing', () async {
    final directory = await Directory.systemTemp.createTemp('templates_test');
    addTearDown(() => directory.delete(recursive: true));
    final repository = JsonFileTemplateRepository(
      file: File('${directory.path}\\missing.json'),
    );

    final catalog = await repository.load();

    expect(catalog.templates, hasLength(1));
    expect(catalog.selectedTemplate.id, 'default');
  });

  test('save and load round trips template catalog', () async {
    final directory = await Directory.systemTemp.createTemp('templates_test');
    addTearDown(() => directory.delete(recursive: true));
    final repository = JsonFileTemplateRepository(
      file: File('${directory.path}\\templates.json'),
    );
    final template = ImageTemplate(
      id: 'custom',
      name: 'Custom',
      outputWidth: 1000,
      outputHeight: 1500,
      overlayImagePath: 'C:\\frame.png',
      photoSlots: const [
        TemplatePhotoSlot(x: 10, y: 20, width: 300, height: 400),
      ],
    );

    await repository.save(
      TemplateCatalog(selectedTemplateId: 'custom', templates: [template]),
    );
    final loaded = await repository.load();

    expect(loaded.selectedTemplate.id, 'custom');
    expect(loaded.selectedTemplate.outputWidth, 1000);
    expect(loaded.selectedTemplate.overlayImagePath, 'C:\\frame.png');
    expect(loaded.selectedTemplate.photoSlots.single.x, 10);
  });
}
