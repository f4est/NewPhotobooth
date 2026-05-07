import '../../domain/photo/camera_repository.dart';
import '../../domain/photo/captured_photo.dart';

class DevelopmentCameraRepository implements CameraRepository {
  int _counter = 0;

  @override
  Future<CapturedPhoto> capturePhoto({required String sessionId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _counter += 1;
    final capturedAt = DateTime.now();

    return CapturedPhoto(
      id: '$sessionId-photo-$_counter',
      filePath: 'development/$sessionId/photo_$_counter.jpg',
      capturedAt: capturedAt,
    );
  }
}
