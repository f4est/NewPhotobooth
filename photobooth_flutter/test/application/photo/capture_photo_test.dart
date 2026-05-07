import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/photo/capture_photo.dart';
import 'package:photobooth_flutter/src/application/photo/start_photo_session.dart';
import 'package:photobooth_flutter/src/domain/photo/camera_repository.dart';
import 'package:photobooth_flutter/src/domain/photo/captured_photo.dart';
import 'package:photobooth_flutter/src/domain/photo/photo_capture_settings.dart';

void main() {
  test('capture adds a photo to the active session', () async {
    final session = StartPhotoSession().call(
      eventName: 'Wedding',
      settings: const PhotoCaptureSettings(photoCount: 2),
      now: DateTime(2026, 5, 6),
    );
    final useCase = CapturePhoto(cameraRepository: _FakeCameraRepository());

    final updated = await useCase(session);

    expect(updated.photos, hasLength(1));
    expect(updated.remainingShots, 1);
    expect(updated.photos.single.filePath, endsWith('photo_1.jpg'));
  });

  test('capture rejects a complete session', () async {
    final session = StartPhotoSession().call(
      eventName: 'Wedding',
      settings: const PhotoCaptureSettings(photoCount: 1),
      now: DateTime(2026, 5, 6),
    );
    final useCase = CapturePhoto(cameraRepository: _FakeCameraRepository());
    final complete = await useCase(session);

    expect(() => useCase(complete), throwsStateError);
  });
}

class _FakeCameraRepository implements CameraRepository {
  int _counter = 0;

  @override
  Future<CapturedPhoto> capturePhoto({required String sessionId}) async {
    _counter += 1;

    return CapturedPhoto(
      id: '$sessionId-photo-$_counter',
      filePath: '$sessionId/photo_$_counter.jpg',
      capturedAt: DateTime(2026, 5, 6, 12, _counter),
    );
  }
}
