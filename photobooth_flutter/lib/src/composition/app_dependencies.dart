import '../presentation/camera/camera_discovery_controller.dart';
import '../presentation/camera/camera_preview_controller.dart';
import '../presentation/events/event_controller.dart';
import '../presentation/gallery/media_gallery_controller.dart';
import '../presentation/photo/photo_booth_controller.dart';
import '../presentation/printing/media_print_controller.dart';
import '../presentation/printing/printer_controller.dart';
import '../presentation/settings/settings_controller.dart';
import '../presentation/sharing/sharing_delivery_controller.dart';
import '../presentation/sharing/sharing_controller.dart';
import '../presentation/templates/template_controller.dart';

class AppDependencies {
  const AppDependencies({
    required this.photoBoothController,
    required this.mediaPrintController,
    required this.settingsController,
    required this.printerController,
    required this.eventController,
    required this.mediaGalleryController,
    required this.sharingController,
    required this.sharingDeliveryController,
    required this.cameraDiscoveryController,
    required this.cameraPreviewController,
    required this.templateController,
  });

  final PhotoBoothController photoBoothController;
  final MediaPrintController mediaPrintController;
  final SettingsController settingsController;
  final PrinterController printerController;
  final EventController eventController;
  final MediaGalleryController mediaGalleryController;
  final SharingController sharingController;
  final SharingDeliveryController sharingDeliveryController;
  final CameraDiscoveryController cameraDiscoveryController;
  final BoothCameraPreviewController cameraPreviewController;
  final TemplateController templateController;
}
