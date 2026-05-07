import '../../domain/photo/camera_repository.dart';
import '../../domain/photo/photo_session.dart';

class CapturePhoto {
  const CapturePhoto({required CameraRepository cameraRepository})
    : _cameraRepository = cameraRepository;

  final CameraRepository _cameraRepository;

  Future<PhotoSession> call(PhotoSession session) async {
    if (session.isComplete) {
      throw StateError('Cannot capture more photos for a complete session.');
    }

    final photo = await _cameraRepository.capturePhoto(sessionId: session.id);
    return session.addPhoto(photo);
  }
}
