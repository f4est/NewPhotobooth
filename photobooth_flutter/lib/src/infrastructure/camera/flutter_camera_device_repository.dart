import 'package:camera/camera.dart';

import '../../domain/camera/camera_device.dart';
import '../../domain/camera/camera_device_repository.dart';

class FlutterCameraDeviceRepository implements CameraDeviceRepository {
  @override
  Future<List<CameraDevice>> listCameras() async {
    final cameras = await availableCameras();
    return [
      for (final camera in cameras)
        CameraDevice(id: camera.name, name: _displayName(camera)),
    ];
  }

  String _displayName(CameraDescription camera) {
    final direction = camera.lensDirection.name;
    return '${camera.name} ($direction)';
  }
}
