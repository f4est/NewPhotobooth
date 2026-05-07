class ImageTemplate {
  const ImageTemplate({
    required this.id,
    required this.name,
    required this.outputWidth,
    required this.outputHeight,
    required this.photoSlots,
    this.overlayImagePath = '',
  }) : assert(outputWidth > 0),
       assert(outputHeight > 0),
       assert(photoSlots.length > 0);

  factory ImageTemplate.defaultTemplate() {
    return ImageTemplate(
      id: 'default',
      name: 'Default 4x6',
      outputWidth: 1200,
      outputHeight: 1800,
      photoSlots: const [
        TemplatePhotoSlot(x: 48, y: 48, width: 1104, height: 804),
        TemplatePhotoSlot(x: 48, y: 948, width: 1104, height: 804),
      ],
    );
  }

  final String id;
  final String name;
  final int outputWidth;
  final int outputHeight;
  final List<TemplatePhotoSlot> photoSlots;
  final String overlayImagePath;

  ImageTemplate copyWith({
    String? id,
    String? name,
    int? outputWidth,
    int? outputHeight,
    List<TemplatePhotoSlot>? photoSlots,
    String? overlayImagePath,
  }) {
    return ImageTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      outputWidth: outputWidth ?? this.outputWidth,
      outputHeight: outputHeight ?? this.outputHeight,
      photoSlots: photoSlots ?? this.photoSlots,
      overlayImagePath: overlayImagePath ?? this.overlayImagePath,
    );
  }
}

class TemplatePhotoSlot {
  const TemplatePhotoSlot({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  }) : assert(width > 0),
       assert(height > 0);

  final int x;
  final int y;
  final int width;
  final int height;

  TemplatePhotoSlot copyWith({int? x, int? y, int? width, int? height}) {
    return TemplatePhotoSlot(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}

class TemplateCatalog {
  const TemplateCatalog({
    required this.selectedTemplateId,
    required this.templates,
  });

  factory TemplateCatalog.initial() {
    final template = ImageTemplate.defaultTemplate();
    return TemplateCatalog(
      selectedTemplateId: template.id,
      templates: [template],
    );
  }

  final String selectedTemplateId;
  final List<ImageTemplate> templates;

  ImageTemplate get selectedTemplate {
    return templates.firstWhere(
      (template) => template.id == selectedTemplateId,
      orElse: ImageTemplate.defaultTemplate,
    );
  }

  TemplateCatalog copyWith({
    String? selectedTemplateId,
    List<ImageTemplate>? templates,
  }) {
    return TemplateCatalog(
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      templates: templates ?? this.templates,
    );
  }
}
