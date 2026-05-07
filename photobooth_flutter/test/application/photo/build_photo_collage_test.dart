import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/photo/build_photo_collage.dart';
import 'package:photobooth_flutter/src/domain/photo/captured_photo.dart';
import 'package:photobooth_flutter/src/domain/photo/collage_layout.dart';
import 'package:photobooth_flutter/src/domain/photo/collage_renderer.dart';
import 'package:photobooth_flutter/src/domain/photo/photo_capture_settings.dart';
import 'package:photobooth_flutter/src/domain/photo/photo_collage.dart';
import 'package:photobooth_flutter/src/domain/photo/photo_session.dart';
import 'package:photobooth_flutter/src/domain/settings/app_settings.dart';

void main() {
  test('builds a collage from a complete photo session', () async {
    final session = _sessionWithPhotos(2);
    final renderer = _FakeCollageRenderer();
    final useCase = BuildPhotoCollage(collageRenderer: renderer);

    final collage = await useCase(session);

    expect(collage.sourcePhotos, hasLength(2));
    expect(collage.layout.slots, hasLength(2));
    expect(collage.filePath, 'session-1/collage.jpg');
    expect(renderer.lastSessionId, 'session-1');
  });

  test('rejects incomplete sessions', () {
    final session = PhotoSession(
      id: 'session-1',
      eventName: 'Event',
      settings: const PhotoCaptureSettings(photoCount: 2),
    );
    final useCase = BuildPhotoCollage(collageRenderer: _FakeCollageRenderer());

    expect(() => useCase(session), throwsStateError);
  });

  test('uses requested layout preset', () async {
    final session = _sessionWithPhotos(3);
    final renderer = _FakeCollageRenderer();
    final useCase = BuildPhotoCollage(collageRenderer: renderer);

    final collage = await useCase(
      session,
      preset: CollageLayoutPreset.stripHorizontal,
    );

    expect(collage.layout.canvasWidth, 1800);
    expect(collage.layout.canvasHeight, 1200);
  });
}

PhotoSession _sessionWithPhotos(int count) {
  var session = PhotoSession(
    id: 'session-1',
    eventName: 'Event',
    settings: PhotoCaptureSettings(photoCount: count),
  );

  for (var index = 0; index < count; index += 1) {
    session = session.addPhoto(
      CapturedPhoto(
        id: 'photo-$index',
        filePath: 'photo_$index.jpg',
        capturedAt: DateTime(2026, 5, 6, 12, index),
      ),
    );
  }

  return session;
}

class _FakeCollageRenderer implements CollageRenderer {
  String? lastSessionId;

  @override
  Future<PhotoCollage> render({
    required String sessionId,
    required List<CapturedPhoto> photos,
    required CollageLayout layout,
  }) async {
    lastSessionId = sessionId;

    return PhotoCollage(
      id: '$sessionId-collage',
      filePath: '$sessionId/collage.jpg',
      sourcePhotos: photos,
      layout: layout,
      createdAt: DateTime(2026, 5, 6),
    );
  }
}
