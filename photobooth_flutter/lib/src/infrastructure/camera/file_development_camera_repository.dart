import 'dart:io';

import 'package:image/image.dart' as img;

import '../../domain/media/media_output_location_repository.dart';
import '../../domain/photo/camera_repository.dart';
import '../../domain/photo/captured_photo.dart';
import '../media/safe_path.dart';

class FileDevelopmentCameraRepository implements CameraRepository {
  FileDevelopmentCameraRepository({
    required MediaOutputLocationRepository outputLocationRepository,
  }) : _outputLocationRepository = outputLocationRepository;

  final MediaOutputLocationRepository _outputLocationRepository;
  int _counter = 0;

  @override
  Future<CapturedPhoto> capturePhoto({required String sessionId}) async {
    _counter += 1;
    final capturedAt = DateTime.now();
    final location = await _outputLocationRepository.current();
    final directory = Directory(
      '${location.baseFolder}\\${safePathSegment(location.eventName)}\\photos',
    );
    await directory.create(recursive: true);

    final file = File(
      '${directory.path}\\${_timestamp(capturedAt)}_${_counter.toString().padLeft(3, '0')}.jpg',
    );
    final jpeg = _buildPlaceholderJpeg(
      label: 'Photo $_counter',
      timestamp: capturedAt,
    );
    await file.writeAsBytes(jpeg, flush: true);

    return CapturedPhoto(
      id: '$sessionId-photo-$_counter',
      filePath: file.path,
      capturedAt: capturedAt,
    );
  }

  List<int> _buildPlaceholderJpeg({
    required String label,
    required DateTime timestamp,
  }) {
    final image = img.Image(width: 1280, height: 853);
    img.fill(image, color: img.ColorRgb8(232, 238, 247));
    img.fillRect(
      image,
      x1: 60,
      y1: 60,
      x2: 1220,
      y2: 793,
      color: img.ColorRgb8(37, 99, 235),
    );
    img.fillRect(
      image,
      x1: 90,
      y1: 90,
      x2: 1190,
      y2: 763,
      color: img.ColorRgb8(255, 255, 255),
    );
    img.drawString(
      image,
      label,
      font: img.arial48,
      x: 420,
      y: 330,
      color: img.ColorRgb8(23, 32, 51),
    );
    img.drawString(
      image,
      _timestamp(timestamp),
      font: img.arial24,
      x: 440,
      y: 405,
      color: img.ColorRgb8(100, 116, 139),
    );
    return img.encodeJpg(image, quality: 92);
  }

  String _timestamp(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    String three(int number) => number.toString().padLeft(3, '0');
    return '${value.year}${two(value.month)}${two(value.day)}_'
        '${two(value.hour)}${two(value.minute)}${two(value.second)}_'
        '${three(value.millisecond)}';
  }
}
