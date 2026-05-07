import 'download_link.dart';

abstract interface class DownloadLinkRepository {
  Future<DownloadLink> createForFile(String filePath);

  Future<void> dispose();
}
