import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/domain/photo/captured_photo.dart';
import 'package:photobooth_flutter/src/domain/photo/photo_capture_settings.dart';
import 'package:photobooth_flutter/src/domain/photo/photo_session.dart';

void main() {
  test('session tracks remaining shots immutably', () {
    final session = PhotoSession(
      id: 'session-1',
      eventName: 'Event',
      settings: const PhotoCaptureSettings(photoCount: 2),
    );

    final updated = session.addPhoto(
      CapturedPhoto(
        id: 'photo-1',
        filePath: 'photo_1.jpg',
        capturedAt: DateTime(2026, 5, 6),
      ),
    );

    expect(session.photos, isEmpty);
    expect(updated.photos, hasLength(1));
    expect(updated.remainingShots, 1);
  });

  test('session becomes complete after the requested number of photos', () {
    final session =
        PhotoSession(
          id: 'session-1',
          eventName: 'Event',
          settings: const PhotoCaptureSettings(photoCount: 1),
        ).addPhoto(
          CapturedPhoto(
            id: 'photo-1',
            filePath: 'photo_1.jpg',
            capturedAt: DateTime(2026, 5, 6),
          ),
        );

    expect(session.isComplete, isTrue);
    expect(session.remainingShots, 0);
  });
}
