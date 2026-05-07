import 'dart:io';

import 'package:image/image.dart' as img;

import '../../domain/media/media_output_location_repository.dart';
import '../../domain/photo/captured_photo.dart';
import '../../domain/photo/collage_layout.dart';
import '../../domain/photo/collage_renderer.dart';
import '../../domain/photo/photo_collage.dart';
import '../../domain/templates/image_template.dart';
import '../../domain/templates/selected_template_repository.dart';
import '../media/safe_path.dart';

class FileCollageRenderer implements CollageRenderer {
  const FileCollageRenderer({
    required MediaOutputLocationRepository outputLocationRepository,
    SelectedTemplateRepository? selectedTemplateRepository,
  }) : _outputLocationRepository = outputLocationRepository,
       _selectedTemplateRepository = selectedTemplateRepository;

  final MediaOutputLocationRepository _outputLocationRepository;
  final SelectedTemplateRepository? _selectedTemplateRepository;

  @override
  Future<PhotoCollage> render({
    required String sessionId,
    required List<CapturedPhoto> photos,
    required CollageLayout layout,
  }) async {
    final createdAt = DateTime.now();
    final template = await _selectedTemplateRepository?.loadSelectedTemplate();
    final activeLayout = template == null
        ? layout
        : _layoutFromTemplate(template);
    final canvas = img.Image(
      width: activeLayout.canvasWidth.round(),
      height: activeLayout.canvasHeight.round(),
    );
    img.fill(canvas, color: img.ColorRgb8(255, 255, 255));

    for (var index = 0; index < photos.length; index += 1) {
      if (index >= activeLayout.slots.length) {
        break;
      }
      final slot = activeLayout.slots[index];
      final sourceBytes = await File(photos[index].filePath).readAsBytes();
      final source = img.decodeImage(sourceBytes);
      if (source == null) {
        continue;
      }

      final fitted = img.copyResizeCropSquare(
        source,
        size: slot.width.round().clamp(1, 10000),
      );
      final resized = img.copyResize(
        fitted,
        width: slot.width.round(),
        height: slot.height.round(),
      );
      img.compositeImage(
        canvas,
        resized,
        dstX: slot.left.round(),
        dstY: slot.top.round(),
      );
    }

    if (template != null) {
      await _drawOverlay(canvas, template.overlayImagePath);
    }
    _drawBorder(canvas);
    final location = await _outputLocationRepository.current();
    final directory = Directory(
      '${location.baseFolder}\\${safePathSegment(location.eventName)}\\collages',
    );
    await directory.create(recursive: true);
    final file = File(
      '${directory.path}\\collage_${_timestamp(createdAt)}.jpg',
    );
    await file.writeAsBytes(img.encodeJpg(canvas, quality: 94), flush: true);

    return PhotoCollage(
      id: '$sessionId-collage',
      filePath: file.path,
      sourcePhotos: List.unmodifiable(photos),
      layout: activeLayout,
      createdAt: createdAt,
    );
  }

  CollageLayout _layoutFromTemplate(ImageTemplate template) {
    return CollageLayout(
      canvasWidth: template.outputWidth.toDouble(),
      canvasHeight: template.outputHeight.toDouble(),
      slots: [
        for (final slot in template.photoSlots)
          CollageSlot(
            left: slot.x.toDouble(),
            top: slot.y.toDouble(),
            width: slot.width.toDouble(),
            height: slot.height.toDouble(),
          ),
      ],
    );
  }

  Future<void> _drawOverlay(img.Image canvas, String overlayPath) async {
    if (overlayPath.trim().isEmpty) {
      return;
    }
    final file = File(overlayPath);
    if (!await file.exists()) {
      return;
    }
    final overlay = img.decodeImage(await file.readAsBytes());
    if (overlay == null) {
      return;
    }
    final resized = img.copyResize(
      overlay,
      width: canvas.width,
      height: canvas.height,
    );
    img.compositeImage(canvas, resized);
  }

  void _drawBorder(img.Image image) {
    final color = img.ColorRgb8(23, 32, 51);
    for (var offset = 0; offset < 8; offset += 1) {
      img.drawRect(
        image,
        x1: offset,
        y1: offset,
        x2: image.width - 1 - offset,
        y2: image.height - 1 - offset,
        color: color,
      );
    }
  }

  String _timestamp(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    String three(int number) => number.toString().padLeft(3, '0');
    return '${value.year}${two(value.month)}${two(value.day)}_'
        '${two(value.hour)}${two(value.minute)}${two(value.second)}_'
        '${three(value.millisecond)}';
  }
}
