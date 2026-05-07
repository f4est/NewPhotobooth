import '../../domain/gallery/media_gallery_repository.dart';

class OpenMediaFile {
  const OpenMediaFile({required MediaGalleryRepository repository})
    : _repository = repository;

  final MediaGalleryRepository _repository;

  Future<void> call(String filePath) => _repository.openFile(filePath);
}
