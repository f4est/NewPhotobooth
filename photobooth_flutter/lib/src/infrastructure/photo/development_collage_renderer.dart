import '../../domain/photo/captured_photo.dart';
import '../../domain/photo/collage_layout.dart';
import '../../domain/photo/collage_renderer.dart';
import '../../domain/photo/photo_collage.dart';

class DevelopmentCollageRenderer implements CollageRenderer {
  @override
  Future<PhotoCollage> render({
    required String sessionId,
    required List<CapturedPhoto> photos,
    required CollageLayout layout,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final createdAt = DateTime.now();

    return PhotoCollage(
      id: '$sessionId-collage',
      filePath: 'development/$sessionId/collage.jpg',
      sourcePhotos: List.unmodifiable(photos),
      layout: layout,
      createdAt: createdAt,
    );
  }
}
