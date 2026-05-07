import '../../domain/photo/photo_capture_settings.dart';
import '../../domain/photo/photo_session.dart';

class StartPhotoSession {
  PhotoSession call({
    required String eventName,
    PhotoCaptureSettings settings = const PhotoCaptureSettings(),
    DateTime? now,
  }) {
    final startedAt = now ?? DateTime.now();

    return PhotoSession(
      id: 'session-${startedAt.microsecondsSinceEpoch}',
      eventName: eventName,
      settings: settings,
    );
  }
}
