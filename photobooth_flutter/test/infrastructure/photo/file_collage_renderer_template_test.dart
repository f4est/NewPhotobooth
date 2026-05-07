import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/domain/media/media_output_location.dart';
import 'package:photobooth_flutter/src/domain/media/media_output_location_repository.dart';
import 'package:photobooth_flutter/src/domain/photo/captured_photo.dart';
import 'package:photobooth_flutter/src/domain/photo/collage_layout.dart';
import 'package:photobooth_flutter/src/domain/templates/image_template.dart';
import 'package:photobooth_flutter/src/domain/templates/selected_template_repository.dart';
import 'package:photobooth_flutter/src/infrastructure/camera/file_development_camera_repository.dart';
import 'package:photobooth_flutter/src/infrastructure/photo/file_collage_renderer.dart';

void main() {
  test('render uses selected template dimensions and slots', () async {
    final directory = await Directory.systemTemp.createTemp('template_render');
    addTearDown(() => directory.delete(recursive: true));
    final output = _FakeOutputLocationRepository(directory.path);
    final camera = FileDevelopmentCameraRepository(
      outputLocationRepository: output,
    );
    final photos = <CapturedPhoto>[
      await camera.capturePhoto(sessionId: 'session-1'),
    ];
    final renderer = FileCollageRenderer(
      outputLocationRepository: output,
      selectedTemplateRepository: const _FakeTemplateRepository(),
    );

    final collage = await renderer.render(
      sessionId: 'session-1',
      photos: photos,
      layout: CollageLayout.grid(photoCount: 1),
    );

    expect(collage.layout.canvasWidth, 900);
    expect(collage.layout.canvasHeight, 1200);
    expect(collage.layout.slots.single.left, 20);
    expect(await File(collage.filePath).exists(), isTrue);
  });
}

class _FakeOutputLocationRepository implements MediaOutputLocationRepository {
  const _FakeOutputLocationRepository(this.baseFolder);

  final String baseFolder;

  @override
  Future<MediaOutputLocation> current() async {
    return MediaOutputLocation(baseFolder: baseFolder, eventName: 'Event');
  }
}

class _FakeTemplateRepository implements SelectedTemplateRepository {
  const _FakeTemplateRepository();

  @override
  Future<ImageTemplate> loadSelectedTemplate() async {
    return ImageTemplate(
      id: 'test',
      name: 'Test',
      outputWidth: 900,
      outputHeight: 1200,
      photoSlots: const [
        TemplatePhotoSlot(x: 20, y: 30, width: 400, height: 500),
      ],
    );
  }
}
