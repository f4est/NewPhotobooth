import 'captured_photo.dart';

abstract interface class CameraRepository {
  Future<CapturedPhoto> capturePhoto({required String sessionId});
}
