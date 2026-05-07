import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/domain/gallery/media_gallery_item.dart';
import 'package:photobooth_flutter/src/domain/media/media_output_location.dart';
import 'package:photobooth_flutter/src/domain/media/media_output_location_repository.dart';
import 'package:photobooth_flutter/src/infrastructure/gallery/file_system_media_gallery_repository.dart';

void main() {
  test('lists current event photos and collages from output folders', () async {
    final temp = await Directory.systemTemp.createTemp('gallery_test_');
    addTearDown(() => temp.delete(recursive: true));

    final eventFolder = Directory('${temp.path}${Platform.pathSeparator}Event');
    final photos = Directory(
      '${eventFolder.path}${Platform.pathSeparator}photos',
    );
    final collages = Directory(
      '${eventFolder.path}${Platform.pathSeparator}collages',
    );
    await photos.create(recursive: true);
    await collages.create(recursive: true);

    final photo = File('${photos.path}${Platform.pathSeparator}photo.jpg');
    final collage = File(
      '${collages.path}${Platform.pathSeparator}collage.png',
    );
    await photo.writeAsBytes([1, 2, 3]);
    await collage.writeAsBytes([1, 2, 3, 4]);
    await photo.setLastModified(DateTime(2026, 5, 6, 12));
    await collage.setLastModified(DateTime(2026, 5, 6, 13));

    final repository = FileSystemMediaGalleryRepository(
      outputLocationRepository: _FakeOutputLocationRepository(temp.path),
    );

    final items = await repository.listCurrentEventMedia();

    expect(items, hasLength(2));
    expect(items.first.fileName, 'collage.png');
    expect(items.first.type, MediaGalleryItemType.collage);
    expect(items.last.type, MediaGalleryItemType.photo);
  });
}

class _FakeOutputLocationRepository implements MediaOutputLocationRepository {
  const _FakeOutputLocationRepository(this.baseFolder);

  final String baseFolder;

  @override
  Future<MediaOutputLocation> current() async {
    return MediaOutputLocation(baseFolder: baseFolder, eventName: 'Event');
  }
}
