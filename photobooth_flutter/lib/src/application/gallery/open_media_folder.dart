import '../../domain/gallery/media_gallery_repository.dart';

class OpenMediaFolder {
  const OpenMediaFolder({required MediaGalleryRepository repository})
    : _repository = repository;

  final MediaGalleryRepository _repository;

  Future<void> call() async {
    final folderPath = await _repository.currentEventFolderPath();
    await _repository.openFolder(folderPath);
  }
}
