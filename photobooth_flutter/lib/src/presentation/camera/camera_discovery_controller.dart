import 'package:flutter/foundation.dart';

import '../../application/camera/list_camera_devices.dart';
import '../../domain/camera/camera_device.dart';

class CameraDiscoveryState {
  const CameraDiscoveryState({
    this.cameras = const [],
    this.isLoading = false,
    this.error,
  });

  final List<CameraDevice> cameras;
  final bool isLoading;
  final String? error;
}

class CameraDiscoveryController extends ValueNotifier<CameraDiscoveryState> {
  CameraDiscoveryController({required ListCameraDevices listCameraDevices})
    : _listCameraDevices = listCameraDevices,
      super(const CameraDiscoveryState());

  final ListCameraDevices _listCameraDevices;

  Future<void> refresh() async {
    value = const CameraDiscoveryState(isLoading: true);
    try {
      final cameras = await _listCameraDevices();
      value = CameraDiscoveryState(cameras: cameras);
    } catch (error) {
      value = CameraDiscoveryState(error: 'Camera discovery failed: $error');
    }
  }
}
