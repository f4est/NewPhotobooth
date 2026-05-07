import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/infrastructure/sharing/local_media_server_download_link_repository.dart';

void main() {
  test('createForFile returns a URL that serves the file bytes', () async {
    final directory = await Directory.systemTemp.createTemp('sharing_test');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}\\result.jpg');
    await file.writeAsBytes([1, 2, 3, 4, 5]);
    final repository = LocalMediaServerDownloadLinkRepository(
      bindAddress: InternetAddress.loopbackIPv4,
    );
    addTearDown(repository.dispose);

    final link = await repository.createForFile(file.path);
    final request = await HttpClient().getUrl(link.url);
    final response = await request.close();
    final bytes = await response.fold<List<int>>(
      <int>[],
      (buffer, chunk) => buffer..addAll(chunk),
    );

    expect(response.statusCode, HttpStatus.ok);
    expect(bytes, [1, 2, 3, 4, 5]);
  });
}
