import '../../domain/templates/image_template.dart';

class TemplateCatalogJsonMapper {
  const TemplateCatalogJsonMapper();

  Map<String, Object?> toJson(TemplateCatalog catalog) {
    return {
      'selectedTemplateId': catalog.selectedTemplateId,
      'templates': catalog.templates.map(_templateToJson).toList(),
    };
  }

  TemplateCatalog fromJson(Map<String, Object?> json) {
    final templates = switch (json['templates']) {
      final List value => value.map(_map).map(_templateFromJson).toList(),
      _ => [ImageTemplate.defaultTemplate()],
    };

    return TemplateCatalog(
      selectedTemplateId: _string(
        json['selectedTemplateId'],
        templates.first.id,
      ),
      templates: templates.isEmpty
          ? [ImageTemplate.defaultTemplate()]
          : templates,
    );
  }

  Map<String, Object?> _templateToJson(ImageTemplate template) {
    return {
      'id': template.id,
      'name': template.name,
      'outputWidth': template.outputWidth,
      'outputHeight': template.outputHeight,
      'overlayImagePath': template.overlayImagePath,
      'photoSlots': template.photoSlots.map(_slotToJson).toList(),
    };
  }

  ImageTemplate _templateFromJson(Map<String, Object?> json) {
    final slots = switch (json['photoSlots']) {
      final List value => value.map(_map).map(_slotFromJson).toList(),
      _ => ImageTemplate.defaultTemplate().photoSlots,
    };

    return ImageTemplate(
      id: _string(json['id'], 'default'),
      name: _string(json['name'], 'Default 4x6'),
      outputWidth: _int(json['outputWidth'], 1200),
      outputHeight: _int(json['outputHeight'], 1800),
      overlayImagePath: _string(json['overlayImagePath'], ''),
      photoSlots: slots.isEmpty
          ? ImageTemplate.defaultTemplate().photoSlots
          : slots,
    );
  }

  Map<String, Object?> _slotToJson(TemplatePhotoSlot slot) {
    return {
      'x': slot.x,
      'y': slot.y,
      'width': slot.width,
      'height': slot.height,
    };
  }

  TemplatePhotoSlot _slotFromJson(Map<String, Object?> json) {
    return TemplatePhotoSlot(
      x: _int(json['x'], 48),
      y: _int(json['y'], 48),
      width: _int(json['width'], 1104),
      height: _int(json['height'], 804),
    );
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  String _string(Object? value, String fallback) {
    return value is String ? value : fallback;
  }

  int _int(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }
}
