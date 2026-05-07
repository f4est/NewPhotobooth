import 'dart:io';

import '../../domain/gallery/media_gallery_item.dart';
import '../../domain/gallery/media_gallery_repository.dart';
import '../../domain/media/media_output_location_repository.dart';
import '../media/safe_path.dart';

class FileSystemMediaGalleryRepository implements MediaGalleryRepository {
  const FileSystemMediaGalleryRepository({
    required MediaOutputLocationRepository outputLocationRepository,
  }) : _outputLocationRepository = outputLocationRepository;

  final MediaOutputLocationRepository _outputLocationRepository;

  @override
  Future<List<MediaGalleryItem>> listCurrentEventMedia() async {
    final eventFolder = Directory(await currentEventFolderPath());
    if (!await eventFolder.exists()) {
      return const [];
    }

    final items = <MediaGalleryItem>[];
    await for (final entity in eventFolder.list(recursive: true)) {
      if (entity is! File || !_isSupportedMedia(entity.path)) {
        continue;
      }

      final stat = await entity.stat();
      items.add(
        MediaGalleryItem(
          filePath: entity.path,
          fileName: entity.uri.pathSegments.last,
          type: _typeFromPath(entity.path),
          modifiedAt: stat.modified,
          sizeBytes: stat.size,
        ),
      );
    }

    items.sort((left, right) => right.modifiedAt.compareTo(left.modifiedAt));
    return items;
  }

  @override
  Future<String> currentEventFolderPath() async {
    final location = await _outputLocationRepository.current();
    return [
      location.baseFolder,
      safePathSegment(location.eventName),
    ].join(Platform.pathSeparator);
  }

  @override
  Future<void> openFile(String filePath) async {
    if (!Platform.isWindows) {
      throw UnsupportedError('Opening files is implemented for Windows.');
    }

    await Process.run('rundll32.exe', [
      'url.dll,FileProtocolHandler',
      filePath,
    ]);
  }

  @override
  Future<void> openFolder(String folderPath) async {
    final folder = Directory(folderPath);
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    if (!Platform.isWindows) {
      throw UnsupportedError('Opening folders is implemented for Windows.');
    }

    await Process.run('explorer.exe', [folderPath]);
  }

  bool _isSupportedMedia(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.mp4') ||
        lower.endsWith('.mov');
  }

  MediaGalleryItemType _typeFromPath(String path) {
    final normalized = path.toLowerCase().replaceAll('\\', '/');
    if (normalized.contains('/collages/')) {
      return MediaGalleryItemType.collage;
    }
    if (normalized.contains('/photos/')) {
      return MediaGalleryItemType.photo;
    }
    return MediaGalleryItemType.other;
  }
}
