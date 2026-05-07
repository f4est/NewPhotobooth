import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../domain/settings/settings_repository.dart';

class CameraPreviewState {
  const CameraPreviewState({
    this.controller,
    this.isInitializing = false,
    this.error,
  });

  final CameraController? controller;
  final bool isInitializing;
  final String? error;

  bool get isReady => controller?.value.isInitialized ?? false;
}

class BoothCameraPreviewController extends ValueNotifier<CameraPreviewState> {
  BoothCameraPreviewController({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      super(const CameraPreviewState());

  final SettingsRepository _settingsRepository;
  CameraDescription? _activeCamera;

  Future<void> initialize() async {
    value = const CameraPreviewState(isInitializing: true);

    try {
      final settings = await _settingsRepository.load();
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        value = const CameraPreviewState(error: 'No cameras found.');
        return;
      }

      final selected = _selectCamera(cameras, settings.camera.cameraName);
      final existing = value.controller;
      if (existing != null &&
          existing.value.isInitialized &&
          _activeCamera?.name == selected.name) {
        value = CameraPreviewState(controller: existing);
        return;
      }

      await existing?.dispose();
      final controller = CameraController(
        selected,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      _activeCamera = selected;
      value = CameraPreviewState(controller: controller);
    } catch (error) {
      value = CameraPreviewState(error: 'Preview failed: $error');
    }
  }

  Future<void> disposePreview() async {
    final controller = value.controller;
    _activeCamera = null;
    value = const CameraPreviewState();
    await controller?.dispose();
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
}
