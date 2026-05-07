import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/sharing/save_media_to_pc.dart';

void main() {
  test('copies media to selected destination', () async {
    final temp = await Directory.systemTemp.createTemp('save-media-');
    final source = File('${temp.path}${Platform.pathSeparator}source.jpg');
    final destination = File(
      '${temp.path}${Platform.pathSeparator}nested${Platform.pathSeparator}copy.jpg',
    );
    await source.writeAsBytes([1, 2, 3, 4]);

    final savedPath = await const SaveMediaToPc()(
      sourcePath: source.path,
      destinationPath: destination.path,
    );

    expect(savedPath, destination.path);
    expect(await destination.readAsBytes(), [1, 2, 3, 4]);

    await temp.delete(recursive: true);
  });

  test('rejects missing source media', () {
    expect(
      () => const SaveMediaToPc()(
        sourcePath: 'missing.jpg',
        destinationPath: 'copy.jpg',
      ),
      throwsStateError,
    );
  });
}
