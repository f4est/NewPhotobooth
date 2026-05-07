import 'package:flutter/material.dart';

import '../camera/camera_discovery_controller.dart';
import '../camera/camera_preview_controller.dart';
import '../events/event_controller.dart';
import '../gallery/media_gallery_controller.dart';
import '../photo/photo_booth_controller.dart';
import '../photo/photo_booth_screen.dart';
import '../printing/media_print_controller.dart';
import '../printing/printer_controller.dart';
import '../settings/settings_controller.dart';
import '../sharing/sharing_delivery_controller.dart';
import '../sharing/sharing_controller.dart';
import '../templates/template_controller.dart';
import 'pages/dashboard_page.dart';
import 'pages/event_management_page.dart';
import 'pages/gallery_page.dart';
import 'pages/image_template_page.dart';
import 'pages/main_settings_page.dart';
import 'pages/print_settings_page.dart';
import 'pages/screen_language_page.dart';
import 'pages/screen_theme_page.dart';
import 'pages/sharing_settings_page.dart';
import 'shell_chrome.dart';

enum AdminSection {
  dashboard('Dashboard', Icons.dashboard_outlined),
  events('Event Management', Icons.event_note_outlined),
  mainSettings('Main Settings', Icons.tune),
  imageTemplate('Image Template', Icons.layers_outlined),
  screenLanguage('Screen Language', Icons.translate),
  screenTheme('Screen Theme', Icons.palette_outlined),
  sharing('Sharing Settings', Icons.share_outlined),
  print('Print Settings', Icons.print_outlined),
  gallery('Gallery', Icons.photo_library_outlined);

  const AdminSection(this.label, this.icon);

  final String label;
  final IconData icon;
}

class PhotoboothAdminShell extends StatefulWidget {
  const PhotoboothAdminShell({
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
    super.key,
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

  @override
  State<PhotoboothAdminShell> createState() => _PhotoboothAdminShellState();
}

class _PhotoboothAdminShellState extends State<PhotoboothAdminShell> {
  AdminSection _selected = AdminSection.dashboard;
  bool _showPhotoApp = false;
  bool _selfServiceAutoStarted = false;

  @override
  Widget build(BuildContext context) {
    _maybeAutoStartSelfService();

    return ShellChrome(
      selected: _selected,
      showPhotoApp: _showPhotoApp,
      onSectionSelected: (section) {
        _leaveBoothForSection(section);
      },
      onStartApp: _openBooth,
      onCloseApp: () {
        _leaveBoothForSection(_selected);
      },
      onSupport: _showSupportDialog,
      onSystem: _showSystemDialog,
      child: _showPhotoApp
          ? PhotoBoothWorkspace(
              controller: widget.photoBoothController,
              sharingController: widget.sharingController,
              sharingDeliveryController: widget.sharingDeliveryController,
              mediaPrintController: widget.mediaPrintController,
              cameraPreviewController: widget.cameraPreviewController,
              settingsController: widget.settingsController,
              onPhotoCaptured: (_) =>
                  widget.eventController.incrementCollected(),
              canPrintPhoto: () => _canPrintAnotherPhoto(),
              canShareMedia: () => _canShareAnotherMedia(),
              onMediaShared: widget.eventController.incrementShared,
              onCollagePrinted: widget.eventController.incrementPrinted,
            )
          : _pageFor(_selected),
    );
  }

  Widget _pageFor(AdminSection section) {
    return switch (section) {
      AdminSection.dashboard => DashboardPage(
        settingsController: widget.settingsController,
        eventController: widget.eventController,
        printerController: widget.printerController,
        mediaGalleryController: widget.mediaGalleryController,
        onOpenBooth: _openBooth,
        onNavigate: (section) {
          if (section == AdminSection.gallery) {
            widget.mediaGalleryController.refresh();
          }
          setState(() => _selected = section);
        },
      ),
      AdminSection.events => EventManagementPage(
        controller: widget.eventController,
      ),
      AdminSection.mainSettings => MainSettingsPage(
        controller: widget.settingsController,
        cameraDiscoveryController: widget.cameraDiscoveryController,
      ),
      AdminSection.imageTemplate => ImageTemplatePage(
        controller: widget.templateController,
      ),
      AdminSection.screenLanguage => ScreenLanguagePage(
        controller: widget.settingsController,
      ),
      AdminSection.screenTheme => ScreenThemePage(
        controller: widget.settingsController,
      ),
      AdminSection.sharing => SharingSettingsPage(
        controller: widget.settingsController,
        deliveryController: widget.sharingDeliveryController,
      ),
      AdminSection.print => PrintSettingsPage(
        controller: widget.settingsController,
        printerController: widget.printerController,
      ),
      AdminSection.gallery => GalleryPage(
        controller: widget.mediaGalleryController,
      ),
    };
  }

  void _openBooth() {
    final settings = widget.settingsController.value.settings;
    widget.photoBoothController.startEventSession(
      eventName: widget.eventController.value.catalog.currentEvent.name,
      countdownSeconds: settings.shooting.countdownSeconds,
      photoCount: settings.shooting.photoCount,
      collageLayoutPreset: settings.shooting.collageLayoutPreset,
    );
    widget.sharingController.clear();
    widget.mediaPrintController.clear();
    widget.mediaGalleryController.refresh();
    widget.cameraPreviewController.initialize();
    setState(() => _showPhotoApp = true);
  }

  void _maybeAutoStartSelfService() {
    final state = widget.settingsController.value;
    if (_selfServiceAutoStarted ||
        !state.hasLoaded ||
        !state.settings.selfService.runOnStartup) {
      return;
    }

    _selfServiceAutoStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_showPhotoApp) {
        _openBooth();
      }
    });
  }

  Future<void> _leaveBoothForSection(AdminSection section) async {
    if (_showPhotoApp && !_canExitBoothWithoutPin()) {
      final unlocked = await _requestSecurityPin();
      if (!unlocked) {
        return;
      }
    }

    widget.cameraPreviewController.disposePreview();
    if (section == AdminSection.gallery) {
      widget.mediaGalleryController.refresh();
    }
    setState(() {
      _selected = section;
      _showPhotoApp = false;
    });
  }

  bool _canExitBoothWithoutPin() {
    return widget.settingsController.value.settings.selfService.securityPin
        .trim()
        .isEmpty;
  }

  Future<bool> _requestSecurityPin() async {
    final expectedPin = widget
        .settingsController
        .value
        .settings
        .selfService
        .securityPin
        .trim();
    final controller = TextEditingController();
    var errorText = '';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Admin PIN'),
              content: TextField(
                controller: controller,
                autofocus: true,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Security Pin',
                  errorText: errorText.isEmpty ? null : errorText,
                ),
                onSubmitted: (_) => _submitPin(
                  context,
                  controller.text,
                  expectedPin,
                  setDialogState,
                  (value) => errorText = value,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => _submitPin(
                    context,
                    controller.text,
                    expectedPin,
                    setDialogState,
                    (value) => errorText = value,
                  ),
                  child: const Text('Unlock'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result ?? false;
  }

  void _submitPin(
    BuildContext context,
    String enteredPin,
    String expectedPin,
    void Function(VoidCallback fn) setDialogState,
    ValueChanged<String> setError,
  ) {
    if (enteredPin.trim() == expectedPin) {
      Navigator.of(context).pop(true);
      return;
    }

    setDialogState(() => setError('Incorrect PIN'));
  }

  bool _canPrintAnotherPhoto() {
    final limit = widget
        .settingsController
        .value
        .settings
        .selfService
        .printLimitEachPhoto;
    return limit == 0 ||
        widget.eventController.value.catalog.currentEvent.mediaPrinted < limit;
  }

  bool _canShareAnotherMedia() {
    final limit =
        widget.settingsController.value.settings.selfService.sharingLimit;
    return limit == 0 ||
        widget.eventController.value.catalog.currentEvent.mediaShared < limit;
  }

  Future<void> _showSupportDialog() async {
    final settings = widget.settingsController.value.settings;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Support'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Diagnostics for booth setup, printer setup and media export.',
              ),
              const SizedBox(height: 16),
              _DialogInfoRow(
                label: 'Current event',
                value: widget.eventController.value.catalog.currentEvent.name,
              ),
              _DialogInfoRow(
                label: 'Output folder',
                value: settings.shooting.outputFolder.trim().isEmpty
                    ? 'Default app media folder'
                    : settings.shooting.outputFolder,
              ),
              _DialogInfoRow(
                label: 'Selected camera',
                value: settings.camera.cameraName.trim().isEmpty
                    ? 'Default camera'
                    : settings.camera.cameraName,
              ),
              _DialogInfoRow(
                label: 'Selected printer',
                value: settings.print.selectedPrinter.trim().isEmpty
                    ? 'No printer selected'
                    : settings.print.selectedPrinter,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: widget.mediaGalleryController.openFolder,
                icon: const Icon(Icons.folder_open),
                label: const Text('Open Media Folder'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSystemDialog() async {
    await widget.cameraDiscoveryController.refresh();
    await widget.printerController.refresh();

    if (!mounted) {
      return;
    }

    final settings = widget.settingsController.value.settings;
    final currentEvent = widget.eventController.value.catalog.currentEvent;
    final cameras = widget.cameraDiscoveryController.value.cameras;
    final printers = widget.printerController.value.printers;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Status'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DialogInfoRow(
                  label: 'Booth screen',
                  value: _showPhotoApp ? 'Open' : 'Closed',
                ),
                _DialogInfoRow(label: 'Event', value: currentEvent.name),
                _DialogInfoRow(
                  label: 'Media collected',
                  value: currentEvent.mediaCollected.toString(),
                ),
                _DialogInfoRow(
                  label: 'Media shared',
                  value: currentEvent.mediaShared.toString(),
                ),
                _DialogInfoRow(
                  label: 'Media printed',
                  value: currentEvent.mediaPrinted.toString(),
                ),
                const Divider(height: 24),
                _DialogInfoRow(
                  label: 'Cameras detected',
                  value: cameras.isEmpty
                      ? '0'
                      : cameras.map((camera) => camera.name).join(', '),
                ),
                _DialogInfoRow(
                  label: 'Printers detected',
                  value: printers.isEmpty ? '0' : printers.join(', '),
                ),
                const Divider(height: 24),
                _DialogInfoRow(
                  label: 'Print',
                  value: settings.print.enabled ? 'Enabled' : 'Disabled',
                ),
                _DialogInfoRow(
                  label: 'QR',
                  value: settings.sharing.qrEnabled ? 'Enabled' : 'Disabled',
                ),
                _DialogInfoRow(
                  label: 'Email',
                  value: settings.sharing.mailEnabled ? 'Enabled' : 'Disabled',
                ),
                _DialogInfoRow(
                  label: 'SMS',
                  value: settings.sharing.smsEnabled ? 'Enabled' : 'Disabled',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DialogInfoRow extends StatelessWidget {
  const _DialogInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(child: SelectableText(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}
