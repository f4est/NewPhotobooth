import 'captured_photo.dart';
import 'collage_layout.dart';

class PhotoCollage {
  const PhotoCollage({
    required this.id,
    required this.filePath,
    required this.sourcePhotos,
    required this.layout,
    required this.createdAt,
  });

  final String id;
  final String filePath;
  final List<CapturedPhoto> sourcePhotos;
  final CollageLayout layout;
  final DateTime createdAt;
}
