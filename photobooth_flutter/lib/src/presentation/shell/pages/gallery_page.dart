import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/gallery/media_gallery_item.dart';
import '../../gallery/media_gallery_controller.dart';
import '../shell_chrome.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({required this.controller, super.key});

  final MediaGalleryController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MediaGalleryState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final photos = state.items
            .where((item) => item.type == MediaGalleryItemType.photo)
            .length;
        final collages = state.items
            .where((item) => item.type == MediaGalleryItemType.collage)
            .length;

        return AdminPage(
          title: 'Gallery',
          subtitle: 'Review media generated for the current event.',
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            AdminPanel(
              title: 'Current Event Media',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      _GalleryCounter(label: 'Photos', value: photos),
                      const SizedBox(width: 12),
                      _GalleryCounter(label: 'Collages', value: collages),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: controller.refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: controller.openFolder,
                        icon: const Icon(Icons.folder_open),
                        label: const Text('Open Folder'),
                      ),
                    ],
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                  if (state.message != null) ...[
                    const SizedBox(height: 12),
                    Text(state.message!),
                  ],
                  const SizedBox(height: 18),
                  if (state.items.isEmpty && !state.isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No media has been created for this event yet.',
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 220,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.78,
                          ),
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final item = state.items[index];
                        return _MediaTile(
                          item: item,
                          onOpen: () => controller.openFile(item.filePath),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GalleryCounter extends StatelessWidget {
  const _GalleryCounter({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffcbd5e1)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.item, required this.onOpen});

  final MediaGalleryItem item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffe2e8f0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: _MediaPreview(item: item),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_typeLabel(item.type)} • ${_formatBytes(item.sizeBytes)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.item});

  final MediaGalleryItem item;

  @override
  Widget build(BuildContext context) {
    final lower = item.filePath.toLowerCase();
    final isImage =
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png');

    if (isImage) {
      return Image.file(File(item.filePath), fit: BoxFit.cover);
    }

    return const ColoredBox(
      color: Color(0xff0f172a),
      child: Center(
        child: Icon(Icons.movie_outlined, size: 44, color: Colors.white),
      ),
    );
  }
}

String _typeLabel(MediaGalleryItemType type) {
  return switch (type) {
    MediaGalleryItemType.photo => 'Photo',
    MediaGalleryItemType.collage => 'Collage',
    MediaGalleryItemType.other => 'Media',
  };
}

String _formatBytes(int bytes) {
  if (bytes >= 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  if (bytes >= 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  }
  return '$bytes B';
}
