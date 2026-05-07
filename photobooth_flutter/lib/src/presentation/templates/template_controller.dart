import 'package:flutter/foundation.dart';

import '../../application/templates/load_templates.dart';
import '../../application/templates/save_templates.dart';
import '../../domain/templates/image_template.dart';

class TemplateState {
  const TemplateState({
    required this.catalog,
    this.isLoading = false,
    this.isSaving = false,
    this.message,
  });

  factory TemplateState.initial() {
    return TemplateState(catalog: TemplateCatalog.initial());
  }

  final TemplateCatalog catalog;
  final bool isLoading;
  final bool isSaving;
  final String? message;

  TemplateState copyWith({
    TemplateCatalog? catalog,
    bool? isLoading,
    bool? isSaving,
    String? message,
  }) {
    return TemplateState(
      catalog: catalog ?? this.catalog,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      message: message,
    );
  }
}

class TemplateController extends ValueNotifier<TemplateState> {
  TemplateController({
    required LoadTemplates loadTemplates,
    required SaveTemplates saveTemplates,
  }) : _loadTemplates = loadTemplates,
       _saveTemplates = saveTemplates,
       super(TemplateState.initial());

  final LoadTemplates _loadTemplates;
  final SaveTemplates _saveTemplates;

  Future<void> load() async {
    value = value.copyWith(isLoading: true);
    final catalog = await _loadTemplates();
    value = TemplateState(catalog: catalog);
  }

  Future<void> updateSelected(ImageTemplate template) async {
    final templates = [
      for (final current in value.catalog.templates)
        if (current.id == template.id) template else current,
    ];
    await _saveCatalog(
      value.catalog.copyWith(templates: templates),
      message: 'Template saved',
    );
  }

  Future<void> setOverlayPath(String path) async {
    await updateSelected(
      value.catalog.selectedTemplate.copyWith(overlayImagePath: path.trim()),
    );
  }

  Future<void> updateSlot(int index, TemplatePhotoSlot slot) async {
    final template = value.catalog.selectedTemplate;
    if (index < 0 || index >= template.photoSlots.length) {
      return;
    }
    final slots = [...template.photoSlots];
    slots[index] = _clampSlot(slot, template);
    await updateSelected(template.copyWith(photoSlots: slots));
  }

  Future<void> addSlot() async {
    final template = value.catalog.selectedTemplate;
    await updateSelected(
      template.copyWith(
        photoSlots: [
          ...template.photoSlots,
          const TemplatePhotoSlot(x: 48, y: 48, width: 500, height: 500),
        ],
      ),
    );
  }

  Future<void> removeSlot(int index) async {
    final template = value.catalog.selectedTemplate;
    if (template.photoSlots.length <= 1 ||
        index < 0 ||
        index >= template.photoSlots.length) {
      return;
    }
    final slots = [...template.photoSlots]..removeAt(index);
    await updateSelected(template.copyWith(photoSlots: slots));
  }

  Future<void> _saveCatalog(TemplateCatalog catalog, {String? message}) async {
    value = value.copyWith(catalog: catalog, isSaving: true);
    await _saveTemplates(catalog);
    value = value.copyWith(isSaving: false, message: message);
  }

  TemplatePhotoSlot _clampSlot(TemplatePhotoSlot slot, ImageTemplate template) {
    final width = slot.width.clamp(1, template.outputWidth);
    final height = slot.height.clamp(1, template.outputHeight);
    final x = slot.x.clamp(0, template.outputWidth - width);
    final y = slot.y.clamp(0, template.outputHeight - height);
    return TemplatePhotoSlot(x: x, y: y, width: width, height: height);
  }
}
