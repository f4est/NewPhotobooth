import 'captured_photo.dart';
import 'photo_capture_settings.dart';

class PhotoSession {
  PhotoSession({
    required this.id,
    required this.eventName,
    required this.settings,
    List<CapturedPhoto> photos = const [],
  }) : _photos = List.unmodifiable(photos);

  final String id;
  final String eventName;
  final PhotoCaptureSettings settings;
  final List<CapturedPhoto> _photos;

  List<CapturedPhoto> get photos => _photos;

  int get remainingShots => settings.photoCount - _photos.length;

  bool get isComplete => remainingShots == 0;

  PhotoSession addPhoto(CapturedPhoto photo) {
    if (isComplete) {
      throw StateError('Photo session already has all required photos.');
    }

    return PhotoSession(
      id: id,
      eventName: eventName,
      settings: settings,
      photos: [..._photos, photo],
    );
  }
}
