import '../application/camera/list_camera_devices.dart';
import '../application/events/load_events.dart';
import '../application/events/save_events.dart';
import '../application/gallery/load_media_gallery.dart';
import '../application/gallery/open_media_file.dart';
import '../application/gallery/open_media_folder.dart';
import '../application/photo/build_photo_collage.dart';
import '../application/photo/capture_photo.dart';
import '../application/printing/list_printers.dart';
import '../application/printing/print_image_file.dart';
import '../application/printing/print_media.dart';
import '../application/printing/print_test_page.dart';
import '../application/settings/load_settings.dart';
import '../application/settings/save_settings.dart';
import '../application/sharing/create_download_link.dart';
import '../application/sharing/generate_qr_code.dart';
import '../application/sharing/send_media_email.dart';
import '../application/sharing/send_media_sms.dart';
import '../application/sharing/send_test_email.dart';
import '../application/sharing/send_test_sms.dart';
import '../application/sharing/save_media_to_pc.dart';
import '../application/system/apply_startup_preference.dart';
import '../application/templates/load_templates.dart';
import '../application/templates/save_templates.dart';
import '../composition/app_dependencies.dart';
import '../infrastructure/camera/flutter_camera_device_repository.dart';
import '../infrastructure/camera/flutter_webcam_camera_repository.dart';
import '../infrastructure/events/json_file_event_repository.dart';
import '../infrastructure/gallery/file_system_media_gallery_repository.dart';
import '../infrastructure/media/settings_event_media_output_location_repository.dart';
import '../infrastructure/photo/file_collage_renderer.dart';
import '../infrastructure/printing/windows_printer_repository.dart';
import '../infrastructure/settings/json_file_settings_repository.dart';
import '../infrastructure/sharing/local_media_server_download_link_repository.dart';
import '../infrastructure/sharing/mailer_email_sender.dart';
import '../infrastructure/sharing/png_qr_code_generator.dart';
import '../infrastructure/sharing/twilio_sms_sender.dart';
import '../infrastructure/system/windows_startup_repository.dart';
import '../infrastructure/templates/json_file_template_repository.dart';
import '../infrastructure/templates/json_selected_template_repository.dart';
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

AppDependencies buildProductionDependencies() {
  final settingsRepository = JsonFileSettingsRepository(
    file: defaultSettingsFile(),
  );
  final eventRepository = JsonFileEventRepository(file: defaultEventsFile());
  final templateRepository = JsonFileTemplateRepository(
    file: defaultTemplatesFile(),
  );
  final outputLocationRepository = SettingsEventMediaOutputLocationRepository(
    settingsRepository: settingsRepository,
    eventRepository: eventRepository,
  );
  final cameraRepository = FlutterWebcamCameraRepository(
    outputLocationRepository: outputLocationRepository,
    settingsRepository: settingsRepository,
  );
  final collageRenderer = FileCollageRenderer(
    outputLocationRepository: outputLocationRepository,
    selectedTemplateRepository: JsonSelectedTemplateRepository(
      repository: templateRepository,
    ),
  );
  final capturePhoto = CapturePhoto(cameraRepository: cameraRepository);
  final buildPhotoCollage = BuildPhotoCollage(collageRenderer: collageRenderer);
  final settingsController = SettingsController(
    loadSettings: LoadSettings(repository: settingsRepository),
    saveSettings: SaveSettings(repository: settingsRepository),
    applyStartupPreference: ApplyStartupPreference(
      repository: WindowsStartupRepository(),
    ),
  );
  settingsController.load();
  final printerController = PrinterController(
    listPrinters: ListPrinters(repository: WindowsPrinterRepository()),
  );
  printerController.refresh();
  final mediaPrintController = MediaPrintController(
    printMedia: PrintMedia(repository: WindowsPrinterRepository()),
    printImageFile: PrintImageFile(repository: WindowsPrinterRepository()),
    printTestPage: PrintTestPage(repository: WindowsPrinterRepository()),
  );
  final eventController = EventController(
    loadEvents: LoadEvents(repository: eventRepository),
    saveEvents: SaveEvents(repository: eventRepository),
  );
  eventController.load();
  final mediaGalleryRepository = FileSystemMediaGalleryRepository(
    outputLocationRepository: outputLocationRepository,
  );
  final mediaGalleryController = MediaGalleryController(
    loadMediaGallery: LoadMediaGallery(repository: mediaGalleryRepository),
    openMediaFile: OpenMediaFile(repository: mediaGalleryRepository),
    openMediaFolder: OpenMediaFolder(repository: mediaGalleryRepository),
  );
  mediaGalleryController.refresh();
  final sharingController = SharingController(
    createDownloadLink: CreateDownloadLink(
      repository: LocalMediaServerDownloadLinkRepository(),
    ),
    generateQrCode: const GenerateQrCode(generator: PngQrCodeGenerator()),
  );
  final sharingDeliveryController = SharingDeliveryController(
    sendTestEmail: const SendTestEmail(sender: MailerEmailSender()),
    sendMediaEmail: const SendMediaEmail(sender: MailerEmailSender()),
    sendMediaSms: SendMediaSms(sender: TwilioSmsSender()),
    sendTestSms: SendTestSms(sender: TwilioSmsSender()),
    saveMediaToPc: const SaveMediaToPc(),
  );
  final cameraDiscoveryController = CameraDiscoveryController(
    listCameraDevices: ListCameraDevices(
      repository: FlutterCameraDeviceRepository(),
    ),
  );
  cameraDiscoveryController.refresh();
  final cameraPreviewController = BoothCameraPreviewController(
    settingsRepository: settingsRepository,
  );
  final templateController = TemplateController(
    loadTemplates: LoadTemplates(repository: templateRepository),
    saveTemplates: SaveTemplates(repository: templateRepository),
  );
  templateController.load();

  return AppDependencies(
    photoBoothController: PhotoBoothController(
      capturePhoto: capturePhoto,
      buildPhotoCollage: buildPhotoCollage,
    ),
    mediaPrintController: mediaPrintController,
    settingsController: settingsController,
    printerController: printerController,
    eventController: eventController,
    mediaGalleryController: mediaGalleryController,
    sharingController: sharingController,
    sharingDeliveryController: sharingDeliveryController,
    cameraDiscoveryController: cameraDiscoveryController,
    cameraPreviewController: cameraPreviewController,
    templateController: templateController,
  );
}
