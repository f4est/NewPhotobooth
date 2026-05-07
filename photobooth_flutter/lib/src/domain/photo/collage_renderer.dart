import 'captured_photo.dart';
import 'collage_layout.dart';
import 'photo_collage.dart';

abstract interface class CollageRenderer {
  Future<PhotoCollage> render({
    required String sessionId,
    required List<CapturedPhoto> photos,
    required CollageLayout layout,
  });
}
