import 'camera_device.dart';

abstract interface class CameraDeviceRepository {
  Future<List<CameraDevice>> listCameras();
}
