import '../../domain/photo/collage_layout.dart';
import '../../domain/photo/collage_renderer.dart';
import '../../domain/photo/photo_collage.dart';
import '../../domain/photo/photo_session.dart';
import '../../domain/settings/app_settings.dart';

class BuildPhotoCollage {
  const BuildPhotoCollage({required CollageRenderer collageRenderer})
    : _collageRenderer = collageRenderer;

  final CollageRenderer _collageRenderer;

  Future<PhotoCollage> call(
    PhotoSession session, {
    CollageLayoutPreset preset = CollageLayoutPreset.grid,
  }) {
    if (!session.isComplete) {
      throw StateError('Cannot build a collage before session is complete.');
    }

    final layout = switch (preset) {
      CollageLayoutPreset.grid => CollageLayout.grid(
        photoCount: session.photos.length,
      ),
      CollageLayoutPreset.stripVertical => CollageLayout.stripVertical(
        photoCount: session.photos.length,
      ),
      CollageLayoutPreset.stripHorizontal => CollageLayout.stripHorizontal(
        photoCount: session.photos.length,
      ),
    };

    return _collageRenderer.render(
      sessionId: session.id,
      photos: session.photos,
      layout: layout,
    );
  }
}
