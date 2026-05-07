import 'dart:io';
import 'dart:math';

import '../../domain/sharing/download_link.dart';
import '../../domain/sharing/download_link_repository.dart';

class LocalMediaServerDownloadLinkRepository implements DownloadLinkRepository {
  LocalMediaServerDownloadLinkRepository({InternetAddress? bindAddress})
    : _bindAddress = bindAddress ?? InternetAddress.anyIPv4;

  final InternetAddress _bindAddress;
  final _routes = <String, File>{};
  final _random = Random.secure();
  HttpServer? _server;
  String? _hostOverride;

  @override
  Future<DownloadLink> createForFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw ArgumentError.value(filePath, 'filePath', 'File does not exist.');
    }

    final server = await _ensureServer();
    final token = _newToken();
    _routes[token] = file;
    final filename = Uri.encodeComponent(file.uri.pathSegments.last);
    final host = _hostOverride ?? await _localNetworkAddress();

    return DownloadLink(
      url: Uri.parse('http://$host:${server.port}/download/$token/$filename'),
      filePath: filePath,
    );
  }

  @override
  Future<void> dispose() async {
    final server = _server;
    _server = null;
    _routes.clear();
    await server?.close(force: true);
  }

  Future<HttpServer> _ensureServer() async {
    final existing = _server;
    if (existing != null) {
      return existing;
    }

    final server = await HttpServer.bind(_bindAddress, 0);
    _server = server;
    _hostOverride = _bindAddress.isLoopback ? _bindAddress.address : null;
    server.listen(_handleRequest);
    return server;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    if (request.method != 'GET' || request.uri.pathSegments.length < 2) {
      await _notFound(request);
      return;
    }

    if (request.uri.pathSegments.first != 'download') {
      await _notFound(request);
      return;
    }

    final token = request.uri.pathSegments[1];
    final file = _routes[token];
    if (file == null || !await file.exists()) {
      await _notFound(request);
      return;
    }

    request.response.headers.contentType = _contentType(file.path);
    request.response.headers.set(
      'Content-Disposition',
      'attachment; filename="${file.uri.pathSegments.last}"',
    );
    request.response.contentLength = await file.length();
    await request.response.addStream(file.openRead());
    await request.response.close();
  }

  Future<void> _notFound(HttpRequest request) async {
    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }

  ContentType _contentType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return ContentType('image', 'jpeg');
    }
    if (lower.endsWith('.png')) {
      return ContentType('image', 'png');
    }
    if (lower.endsWith('.mp4')) {
      return ContentType('video', 'mp4');
    }
    return ContentType.binary;
  }

  String _newToken() {
    final values = List<int>.generate(16, (_) => _random.nextInt(256));
    return values
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  Future<String> _localNetworkAddress() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!address.isLoopback) {
          return address.address;
        }
      }
    }
    return InternetAddress.loopbackIPv4.address;
  }
}
