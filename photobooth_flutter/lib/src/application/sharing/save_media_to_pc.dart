import 'dart:io';

class SaveMediaToPc {
  const SaveMediaToPc();

  Future<String> call({
    required String sourcePath,
    required String destinationPath,
  }) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw StateError('Source media file does not exist: $sourcePath');
    }

    final destination = File(destinationPath);
    await destination.parent.create(recursive: true);
    await source.copy(destination.path);
    return destination.path;
  }
}
