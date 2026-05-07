import '../../domain/sharing/download_link.dart';
import '../../domain/sharing/download_link_repository.dart';

class CreateDownloadLink {
  const CreateDownloadLink({required DownloadLinkRepository repository})
    : _repository = repository;

  final DownloadLinkRepository _repository;

  Future<DownloadLink> call(String filePath) {
    return _repository.createForFile(filePath);
  }

  Future<void> dispose() => _repository.dispose();
}
