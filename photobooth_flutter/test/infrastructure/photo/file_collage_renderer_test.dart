import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/domain/media/media_output_location.dart';
import 'package:photobooth_flutter/src/domain/media/media_output_location_repository.dart';
import 'package:photobooth_flutter/src/domain/photo/captured_photo.dart';
import 'package:photobooth_flutter/src/domain/photo/collage_layout.dart';
import 'package:photobooth_flutter/src/infrastructure/camera/file_development_camera_repository.dart';
import 'package:photobooth_flutter/src/infrastructure/photo/file_collage_renderer.dart';

void main() {
  test('render creates a collage jpeg from captured photos', () async {
    final directory = await Directory.systemTemp.createTemp('collage_test');
    addTearDown(() => directory.delete(recursive: true));
    final output = _FakeOutputLocationRepository(directory.path);
    final camera = FileDevelopmentCameraRepository(
      outputLocationRepository: output,
    );
    final photos = <CapturedPhoto>[
      await camera.capturePhoto(sessionId: 'session-1'),
      await camera.capturePhoto(sessionId: 'session-1'),
    ];
    final renderer = FileCollageRenderer(outputLocationRepository: output);

    final collage = await renderer.render(
      sessionId: 'session-1',
      photos: photos,
      layout: CollageLayout.grid(photoCount: 2),
    );

    final file = File(collage.filePath);
    expect(await file.exists(), isTrue);
    expect(collage.filePath, contains('collages'));
    expect(await file.length(), greaterThan(1000));
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
