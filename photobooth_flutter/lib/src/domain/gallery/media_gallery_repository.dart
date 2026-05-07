import 'media_gallery_item.dart';

abstract interface class MediaGalleryRepository {
  Future<List<MediaGalleryItem>> listCurrentEventMedia();

  Future<String> currentEventFolderPath();

  Future<void> openFile(String filePath);

  Future<void> openFolder(String folderPath);
}
