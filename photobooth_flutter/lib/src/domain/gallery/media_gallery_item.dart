enum MediaGalleryItemType { photo, collage, other }

class MediaGalleryItem {
  const MediaGalleryItem({
    required this.filePath,
    required this.fileName,
    required this.type,
    required this.modifiedAt,
    required this.sizeBytes,
  });

  final String filePath;
  final String fileName;
  final MediaGalleryItemType type;
  final DateTime modifiedAt;
  final int sizeBytes;
}
