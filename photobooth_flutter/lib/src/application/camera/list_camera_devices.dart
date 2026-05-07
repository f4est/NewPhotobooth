import '../../domain/camera/camera_device.dart';
import '../../domain/camera/camera_device_repository.dart';

class ListCameraDevices {
  const ListCameraDevices({required CameraDeviceRepository repository})
    : _repository = repository;

  final CameraDeviceRepository _repository;

  Future<List<CameraDevice>> call() => _repository.listCameras();
}
