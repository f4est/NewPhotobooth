import 'package:flutter/foundation.dart';

import '../../application/gallery/load_media_gallery.dart';
import '../../application/gallery/open_media_file.dart';
import '../../application/gallery/open_media_folder.dart';
import '../../domain/gallery/media_gallery_item.dart';

class MediaGalleryState {
  const MediaGalleryState({
    this.items = const [],
    this.isLoading = false,
    this.message,
    this.errorMessage,
  });

  final List<MediaGalleryItem> items;
  final bool isLoading;
  final String? message;
  final String? errorMessage;

  MediaGalleryState copyWith({
    List<MediaGalleryItem>? items,
    bool? isLoading,
    String? message,
    String? errorMessage,
  }) {
    return MediaGalleryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      message: message,
      errorMessage: errorMessage,
    );
  }
}

class MediaGalleryController extends ValueNotifier<MediaGalleryState> {
  MediaGalleryController({
    required LoadMediaGallery loadMediaGallery,
    required OpenMediaFile openMediaFile,
    required OpenMediaFolder openMediaFolder,
  }) : _loadMediaGallery = loadMediaGallery,
       _openMediaFile = openMediaFile,
       _openMediaFolder = openMediaFolder,
       super(const MediaGalleryState());

  final LoadMediaGallery _loadMediaGallery;
  final OpenMediaFile _openMediaFile;
  final OpenMediaFolder _openMediaFolder;

  Future<void> refresh() async {
    value = value.copyWith(isLoading: true);
    try {
      final items = await _loadMediaGallery();
      value = MediaGalleryState(items: items);
    } catch (error) {
      value = value.copyWith(
        isLoading: false,
        errorMessage: 'Gallery load failed: $error',
      );
    }
  }

  Future<void> openFile(String filePath) async {
    try {
      await _openMediaFile(filePath);
      value = value.copyWith(message: 'File opened');
    } catch (error) {
      value = value.copyWith(errorMessage: 'Open file failed: $error');
    }
  }

  Future<void> openFolder() async {
    try {
      await _openMediaFolder();
      value = value.copyWith(message: 'Folder opened');
    } catch (error) {
      value = value.copyWith(errorMessage: 'Open folder failed: $error');
    }
  }
}
