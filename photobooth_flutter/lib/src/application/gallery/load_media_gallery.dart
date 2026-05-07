import '../../domain/gallery/media_gallery_item.dart';
import '../../domain/gallery/media_gallery_repository.dart';

class LoadMediaGallery {
  const LoadMediaGallery({required MediaGalleryRepository repository})
    : _repository = repository;

  final MediaGalleryRepository _repository;

  Future<List<MediaGalleryItem>> call() => _repository.listCurrentEventMedia();
}
