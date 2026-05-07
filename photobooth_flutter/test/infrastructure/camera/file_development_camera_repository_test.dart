import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/domain/media/media_output_location.dart';
import 'package:photobooth_flutter/src/domain/media/media_output_location_repository.dart';
import 'package:photobooth_flutter/src/infrastructure/camera/file_development_camera_repository.dart';

void main() {
  test('capturePhoto writes a real jpeg file to event photos folder', () async {
    final directory = await Directory.systemTemp.createTemp('camera_test');
    addTearDown(() => directory.delete(recursive: true));
    final repository = FileDevelopmentCameraRepository(
      outputLocationRepository: _FakeOutputLocationRepository(directory.path),
    );

    final photo = await repository.capturePhoto(sessionId: 'session-1');

    final file = File(photo.filePath);
    expect(await file.exists(), isTrue);
    expect(photo.filePath, contains('Wedding Day'));
    expect(await file.length(), greaterThan(1000));
  });
}

class _FakeOutputLocationRepository implements MediaOutputLocationRepository {
  const _FakeOutputLocationRepository(this.baseFolder);

  final String baseFolder;

  @override
  Future<MediaOutputLocation> current() async {
    return MediaOutputLocation(
      baseFolder: baseFolder,
      eventName: 'Wedding Day',
    );
  }
}
