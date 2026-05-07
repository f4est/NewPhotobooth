import 'dart:io';

import 'package:camera/camera.dart';

import '../../domain/media/media_output_location_repository.dart';
import '../../domain/photo/camera_repository.dart';
import '../../domain/photo/captured_photo.dart';
import '../../domain/settings/settings_repository.dart';
import '../media/safe_path.dart';

class FlutterWebcamCameraRepository implements CameraRepository {
  FlutterWebcamCameraRepository({
    required MediaOutputLocationRepository outputLocationRepository,
    required SettingsRepository settingsRepository,
  }) : _outputLocationRepository = outputLocationRepository,
       _settingsRepository = settingsRepository;

  final MediaOutputLocationRepository _outputLocationRepository;
  final SettingsRepository _settingsRepository;
  CameraController? _controller;
  CameraDescription? _activeCamera;
  int _counter = 0;

  @override
  Future<CapturedPhoto> capturePhoto({required String sessionId}) async {
    _counter += 1;
    final capturedAt = DateTime.now();
    final controller = await _readyController();
    final raw = await controller.takePicture();
    final location = await _outputLocationRepository.current();
    final directory = Directory(
      '${location.baseFolder}\\${safePathSegment(location.eventName)}\\photos',
    );
    await directory.create(recursive: true);

    final extension = _extensionFor(raw.path);
    final file = File(
      '${directory.path}\\${_timestamp(capturedAt)}_${_counter.toString().padLeft(3, '0')}$extension',
    );
    await File(raw.path).copy(file.path);

    return CapturedPhoto(
      id: '$sessionId-photo-$_counter',
      filePath: file.path,
      capturedAt: capturedAt,
    );
  }

  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    _activeCamera = null;
    await controller?.dispose();
  }

  Future<CameraController> _readyController() async {
    final settings = await _settingsRepository.load();
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw StateError('No cameras found.');
    }

    final selected = _selectCamera(cameras, settings.camera.cameraName);
    final existing = _controller;
    if (existing != null &&
        existing.value.isInitialized &&
        _activeCamera?.name == selected.name) {
      return existing;
    }

    await existing?.dispose();
    final controller = CameraController(
      selected,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await controller.initialize();
    _controller = controller;
    _activeCamera = selected;
    return controller;
  }

  CameraDescription _selectCamera(
    List<CameraDescription> cameras,
    String configuredName,
  ) {
    final trimmed = configuredName.trim();
    if (trimmed.isEmpty) {
      return cameras.first;
    }

    return cameras.firstWhere(
      (camera) => camera.name == trimmed || camera.name.contains(trimmed),
      orElse: () => cameras.first,
    );
  }

  String _extensionFor(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) {
      return '.png';
    }
    return '.jpg';
  }

  String _timestamp(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    String three(int number) => number.toString().padLeft(3, '0');
    return '${value.year}${two(value.month)}${two(value.day)}_'
        '${two(value.hour)}${two(value.minute)}${two(value.second)}_'
        '${three(value.millisecond)}';
  }
}
