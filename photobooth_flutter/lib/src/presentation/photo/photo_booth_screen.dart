import 'dart:io';

import 'package:camera/camera.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../domain/photo/captured_photo.dart';
import '../../domain/settings/app_settings.dart';
import '../camera/camera_preview_controller.dart';
import '../printing/media_print_controller.dart';
import '../settings/settings_controller.dart';
import '../sharing/sharing_delivery_controller.dart';
import '../sharing/sharing_controller.dart';
import 'photo_booth_controller.dart';

class PhotoBoothScreen extends StatelessWidget {
  const PhotoBoothScreen({
    required this.controller,
    required this.sharingController,
    required this.cameraPreviewController,
    this.mediaPrintController,
    this.sharingDeliveryController,
    this.settingsController,
    this.onCollagePrinted,
    super.key,
  });

  final PhotoBoothController controller;
  final SharingController sharingController;
  final BoothCameraPreviewController cameraPreviewController;
  final MediaPrintController? mediaPrintController;
  final SharingDeliveryController? sharingDeliveryController;
  final SettingsController? settingsController;
  final Future<void> Function()? onCollagePrinted;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PhotoBoothState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final settings = settingsController?.value.settings;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Photo Booth'),
            actions: [
              IconButton(
                tooltip: 'Restart',
                onPressed: state.isCapturing ? null : controller.restartSession,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: _BoothThemeSurface(
            settings: settings,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: _PreviewPanel(
                      previewController: cameraPreviewController,
                      isCapturing: state.isCapturing,
                      isComplete: state.session.isComplete,
                      countdownValue: state.countdownValue,
                      screenTheme: settings?.theme,
                      mirrorPreview: settings?.shooting.mirrorPreview ?? false,
                      rotationDegrees: settings?.camera.rotationDegrees ?? 0,
                      completeLabel: settings?.screenTexts.text(
                        'sessionComplete',
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 360,
                    child: _SessionPanel(
                      state: state,
                      sharingController: sharingController,
                      sharingDeliveryController: sharingDeliveryController,
                      mediaPrintController: mediaPrintController,
                      settingsController: settingsController,
                      onStartSequence: () async {
                        await controller.startSequence(
                          countdownSeconds:
                              state.session.settings.countdownSeconds,
                        );
                        await _prepareResultAfterCapture(
                          controller: controller,
                          sharingController: sharingController,
                          sharingSettings:
                              settings?.sharing ?? const SharingSettings(),
                        );
                      },
                      onDone: () {
                        sharingController.clear();
                        sharingDeliveryController?.clear();
                        mediaPrintController?.clear();
                        controller.restartSession();
                      },
                      onCollagePrinted: onCollagePrinted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PhotoBoothWorkspace extends StatelessWidget {
  const PhotoBoothWorkspace({
    required this.controller,
    required this.sharingController,
    required this.mediaPrintController,
    required this.sharingDeliveryController,
    required this.cameraPreviewController,
    required this.settingsController,
    this.onPhotoCaptured,
    this.canPrintPhoto,
    this.canShareMedia,
    this.onMediaShared,
    this.onCollagePrinted,
    super.key,
  });

  final PhotoBoothController controller;
  final SharingController sharingController;
  final MediaPrintController mediaPrintController;
  final SharingDeliveryController sharingDeliveryController;
  final BoothCameraPreviewController cameraPreviewController;
  final SettingsController settingsController;
  final Future<void> Function(CapturedPhoto photo)? onPhotoCaptured;
  final bool Function()? canPrintPhoto;
  final bool Function()? canShareMedia;
  final Future<void> Function()? onMediaShared;
  final Future<void> Function()? onCollagePrinted;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PhotoBoothState>(
      valueListenable: controller,
      builder: (context, state, _) {
        return ValueListenableBuilder<SettingsState>(
          valueListenable: settingsController,
          builder: (context, settingsState, _) {
            final settings = settingsState.settings;

            final preview = _PreviewPanel(
              previewController: cameraPreviewController,
              isCapturing: state.isCapturing,
              isComplete: state.session.isComplete,
              countdownValue: state.countdownValue,
              screenTheme: settings.theme,
              mirrorPreview: settings.shooting.mirrorPreview,
              rotationDegrees: settings.camera.rotationDegrees,
              completeLabel: settings.screenTexts.text('sessionComplete'),
            );
            final panel = _SessionPanel(
              state: state,
              sharingController: sharingController,
              sharingDeliveryController: sharingDeliveryController,
              mediaPrintController: mediaPrintController,
              settingsController: settingsController,
              onStartSequence: () => controller.startSequence(
                countdownSeconds: state.session.settings.countdownSeconds,
                onPhotoCaptured: (photo) async {
                  await onPhotoCaptured?.call(photo);
                  if (settings.print.onePrintPerPhoto &&
                      settings.print.enabled &&
                      (canPrintPhoto?.call() ?? true)) {
                    final printed = await mediaPrintController.printFile(
                      filePath: photo.filePath,
                      settings: settings.print,
                    );
                    if (printed) {
                      await onCollagePrinted?.call();
                    }
                  }
                },
              ),
              onDone: () {
                sharingController.clear();
                sharingDeliveryController.clear();
                mediaPrintController.clear();
                controller.restartSession();
              },
              onAutoPrepareResult: () async {
                if (!(canShareMedia?.call() ?? true)) {
                  return;
                }
                final shared = await _prepareResultAfterCapture(
                  controller: controller,
                  sharingController: sharingController,
                  sharingSettings: settings.sharing,
                );
                if (shared) {
                  await onMediaShared?.call();
                }
              },
              onMediaShared: onMediaShared,
              canShareMedia: canShareMedia,
              onCollagePrinted: onCollagePrinted,
            );

            return _BoothThemeSurface(
              settings: settings,
              child: settings.shooting.fullscreenPreview
                  ? _FullscreenBoothLayout(preview: preview, panel: panel)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: preview),
                        const SizedBox(width: 24),
                        SizedBox(width: 360, child: panel),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}

Future<bool> _prepareResultAfterCapture({
  required PhotoBoothController controller,
  required SharingController sharingController,
  required SharingSettings sharingSettings,
}) async {
  if (!controller.value.session.isComplete ||
      controller.value.collage != null) {
    return false;
  }

  await controller.buildCollage();
  final collage = controller.value.collage;
  if (collage == null) {
    return false;
  }

  final needsDownloadLink =
      sharingSettings.qrEnabled || sharingSettings.smsEnabled;
  if (!needsDownloadLink) {
    return false;
  }

  await sharingController.createDownloadLink(
    collage.filePath,
    generateQr: sharingSettings.qrEnabled,
  );
  return sharingSettings.qrEnabled &&
      sharingController.value.downloadLink != null;
}

class _BoothThemeSurface extends StatelessWidget {
  const _BoothThemeSurface({required this.child, this.settings});

  final Widget child;
  final AppSettings? settings;

  @override
  Widget build(BuildContext context) {
    final themeSettings = settings?.theme ?? const ScreenThemeSettings();
    final backgroundImage = File(themeSettings.backgroundImagePath);
    final hasBackgroundImage =
        themeSettings.homeBackgroundImageEnabled &&
        themeSettings.backgroundImagePath.trim().isNotEmpty &&
        backgroundImage.existsSync();
    final accent = Color(themeSettings.themeColor);

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(colorScheme: ColorScheme.fromSeed(seedColor: accent)),
      child: Container(
        decoration: BoxDecoration(
          color: Color(themeSettings.homeBackgroundColor),
          image: hasBackgroundImage
              ? DecorationImage(
                  image: FileImage(backgroundImage),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: child,
      ),
    );
  }
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({
    required this.previewController,
    required this.isCapturing,
    required this.isComplete,
    required this.countdownValue,
    required this.mirrorPreview,
    required this.rotationDegrees,
    this.screenTheme,
    this.completeLabel,
  });

  final BoothCameraPreviewController previewController;
  final bool isCapturing;
  final bool isComplete;
  final int? countdownValue;
  final bool mirrorPreview;
  final int rotationDegrees;
  final ScreenThemeSettings? screenTheme;
  final String? completeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColoredBox(
        color: Color(
          screenTheme?.homeBackgroundColor ??
              const ScreenThemeSettings().homeBackgroundColor,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ValueListenableBuilder<CameraPreviewState>(
              valueListenable: previewController,
              builder: (context, previewState, _) {
                if (previewState.isReady) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: _previewTransform(),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width:
                            previewState.controller!.value.previewSize!.height,
                        height:
                            previewState.controller!.value.previewSize!.width,
                        child: CameraPreview(previewState.controller!),
                      ),
                    ),
                  );
                }

                if (previewState.isInitializing) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.videocam_off_outlined,
                        size: 76,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        previewState.error ?? 'Camera preview is not running',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: previewController.initialize,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Start Preview'),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (isCapturing)
              Container(
                color: Colors.black45,
                child: const Center(child: CircularProgressIndicator()),
              ),
            if (countdownValue != null)
              Container(
                color: Colors.black45,
                alignment: Alignment.center,
                child: Text(
                  countdownValue.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 140,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            if (isComplete && !isCapturing)
              Positioned(
                right: 18,
                top: 18,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          completeLabel ?? 'Session complete',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Matrix4 _previewTransform() {
    final transform = Matrix4.identity();
    if (mirrorPreview) {
      transform.multiply(Matrix4.diagonal3Values(-1, 1, 1));
    }
    if (rotationDegrees != 0) {
      transform.rotateZ(rotationDegrees * 3.141592653589793 / 180);
    }
    return transform;
  }
}

class _FullscreenBoothLayout extends StatelessWidget {
  const _FullscreenBoothLayout({required this.preview, required this.panel});

  final Widget preview;
  final Widget panel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        preview,
        Positioned(
          top: 18,
          right: 18,
          bottom: 18,
          width: 360,
          child: Material(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: Padding(padding: const EdgeInsets.all(16), child: panel),
          ),
        ),
      ],
    );
  }
}

class _GuestActions extends StatelessWidget {
  const _GuestActions({
    required this.state,
    required this.screenTexts,
    required this.photoEnabled,
    required this.galleryEnabled,
    required this.onPhoto,
    required this.onGallery,
    required this.onDone,
  });

  final PhotoBoothState state;
  final ScreenTextSettings screenTexts;
  final bool photoEnabled;
  final bool galleryEnabled;
  final Future<void> Function() onPhoto;
  final VoidCallback onGallery;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final canStart =
        photoEnabled &&
        !state.isRunningSequence &&
        !state.isCapturing &&
        !state.session.isComplete;
    final canDone =
        state.session.photos.isNotEmpty &&
        !state.isRunningSequence &&
        !state.isCapturing &&
        !state.isBuildingCollage;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: canStart ? onPhoto : null,
            icon: state.isRunningSequence
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.photo_camera_outlined),
            label: Text(screenTexts.text('photo')),
          ),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          tooltip: screenTexts.text('gallery'),
          onPressed:
              galleryEnabled &&
                  (state.session.photos.isNotEmpty || state.collage != null)
              ? onGallery
              : null,
          icon: const Icon(Icons.photo_library_outlined),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          tooltip: screenTexts.text('done'),
          onPressed: canDone ? onDone : null,
          icon: const Icon(Icons.check),
        ),
      ],
    );
  }
}

Future<void> _showSessionGallery(
  BuildContext context,
  PhotoBoothState state,
  ScreenTextSettings screenTexts,
) async {
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(screenTexts.text('gallery')),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.collage != null)
                  _GalleryFileTile(
                    title: screenTexts.text('collage'),
                    filePath: state.collage!.filePath,
                  ),
                for (
                  var index = 0;
                  index < state.session.photos.length;
                  index += 1
                )
                  _GalleryFileTile(
                    title: '${screenTexts.text('photoItem')} ${index + 1}',
                    filePath: state.session.photos[index].filePath,
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(screenTexts.text('close')),
          ),
        ],
      );
    },
  );
}

class _GalleryFileTile extends StatelessWidget {
  const _GalleryFileTile({required this.title, required this.filePath});

  final String title;
  final String filePath;

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    final exists = file.existsSync();

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 56,
        height: 56,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: exists
              ? Image.file(file, fit: BoxFit.cover)
              : const ColoredBox(
                  color: Color(0xffe5e7eb),
                  child: Icon(Icons.broken_image_outlined),
                ),
        ),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(filePath, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}

class _SessionPanel extends StatelessWidget {
  const _SessionPanel({
    required this.state,
    required this.sharingController,
    required this.sharingDeliveryController,
    required this.mediaPrintController,
    required this.settingsController,
    required this.onStartSequence,
    required this.onDone,
    this.onAutoPrepareResult,
    this.onMediaShared,
    this.canShareMedia,
    this.onCollagePrinted,
  });

  final PhotoBoothState state;
  final SharingController sharingController;
  final SharingDeliveryController? sharingDeliveryController;
  final MediaPrintController? mediaPrintController;
  final SettingsController? settingsController;
  final Future<void> Function() onStartSequence;
  final VoidCallback onDone;
  final Future<void> Function()? onAutoPrepareResult;
  final Future<void> Function()? onMediaShared;
  final bool Function()? canShareMedia;
  final Future<void> Function()? onCollagePrinted;

  @override
  Widget build(BuildContext context) {
    final session = state.session;
    final theme = Theme.of(context);
    final screenTexts =
        settingsController?.value.settings.screenTexts ??
        const ScreenTextSettings();
    final shootingSettings =
        settingsController?.value.settings.shooting ?? const ShootingSettings();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(session.eventName, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          '${session.photos.length}/${session.settings.photoCount} photos',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 20),
        _GuestActions(
          state: state,
          screenTexts: screenTexts,
          photoEnabled: shootingSettings.photoEnabled,
          galleryEnabled: shootingSettings.galleryEnabled,
          onPhoto: () async {
            await onStartSequence();
            await onAutoPrepareResult?.call();
          },
          onGallery: () => _showSessionGallery(context, state, screenTexts),
          onDone: onDone,
        ),
        if (!shootingSettings.photoEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(screenTexts.text('photoDisabled')),
          ),
        if (!shootingSettings.galleryEnabled)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(screenTexts.text('galleryDisabled')),
          ),
        if (state.isBuildingCollage) ...[
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const SizedBox.square(
              dimension: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            title: Text(screenTexts.text('buildCollage')),
          ),
        ],
        if (state.collage != null) ...[
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.collections),
            title: Text(screenTexts.text('collage')),
            subtitle: Text(state.collage!.filePath),
          ),
          ValueListenableBuilder<SharingState>(
            valueListenable: sharingController,
            builder: (context, sharingState, _) {
              if (sharingState.isCreating) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  title: Text(screenTexts.text('qrPreparing')),
                );
              }

              final link = sharingState.downloadLink;
              if (link != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (sharingState.qrCode != null) ...[
                      const SizedBox(height: 8),
                      Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xffe2e8f0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.file(
                              File(sharingState.qrCode!.filePath),
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.qr_code_2),
                      title: Text(screenTexts.text('downloadLink')),
                      subtitle: SelectableText(link.url.toString()),
                    ),
                  ],
                );
              }

              if (sharingState.error != null) {
                return Text(
                  sharingState.error!,
                  style: TextStyle(color: theme.colorScheme.error),
                );
              }

              return const SizedBox.shrink();
            },
          ),
          if (sharingDeliveryController != null &&
              settingsController != null) ...[
            const SizedBox(height: 12),
            _DeliveryActions(
              state: state,
              sharingController: sharingController,
              sharingDeliveryController: sharingDeliveryController!,
              settingsController: settingsController!,
              screenTexts: screenTexts,
              onMediaShared: onMediaShared,
              canShareMedia: canShareMedia,
            ),
          ],
          if (mediaPrintController != null && settingsController != null) ...[
            const SizedBox(height: 12),
            ValueListenableBuilder<MediaPrintState>(
              valueListenable: mediaPrintController!,
              builder: (context, printState, _) {
                final printSettings = settingsController!.value.settings.print;
                final canPrint =
                    printSettings.enabled &&
                    printSettings.selectedPrinter.trim().isNotEmpty &&
                    !printState.isPrinting;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: canPrint
                          ? () async {
                              final printed = await mediaPrintController!
                                  .printCollage(
                                    collage: state.collage!,
                                    settings: printSettings,
                                  );
                              if (printed) {
                                await onCollagePrinted?.call();
                              }
                            }
                          : null,
                      icon: printState.isPrinting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.print),
                      label: Text(
                        printState.isPrinting
                            ? screenTexts.text('printing')
                            : screenTexts.text('printCollage'),
                      ),
                    ),
                    if (!printSettings.enabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(screenTexts.text('printingDisabled')),
                      )
                    else if (printSettings.selectedPrinter.trim().isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(screenTexts.text('selectPrinter')),
                      ),
                    if (printState.message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(printState.message!),
                      ),
                    if (printState.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          printState.errorMessage!,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
        if (state.errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            state.errorMessage!,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: session.photos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final photo = session.photos[index];
              return ListTile(
                leading: const Icon(Icons.image),
                title: Text('${screenTexts.text('photoItem')} ${index + 1}'),
                subtitle: Text(photo.filePath),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DeliveryActions extends StatefulWidget {
  const _DeliveryActions({
    required this.state,
    required this.sharingController,
    required this.sharingDeliveryController,
    required this.settingsController,
    required this.screenTexts,
    this.onMediaShared,
    this.canShareMedia,
  });

  final PhotoBoothState state;
  final SharingController sharingController;
  final SharingDeliveryController sharingDeliveryController;
  final SettingsController settingsController;
  final ScreenTextSettings screenTexts;
  final Future<void> Function()? onMediaShared;
  final bool Function()? canShareMedia;

  @override
  State<_DeliveryActions> createState() => _DeliveryActionsState();
}

class _DeliveryActionsState extends State<_DeliveryActions> {
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final sharing = widget.settingsController.value.settings.sharing;
    _emailController = TextEditingController(text: sharing.receiverEmail);
    _phoneController = TextEditingController(text: sharing.smsTestNumber);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<SharingDeliveryState>(
      valueListenable: widget.sharingDeliveryController,
      builder: (context, deliveryState, _) {
        final sharingSettings =
            widget.settingsController.value.settings.sharing;
        final downloadUrl = widget.sharingController.value.downloadLink?.url;
        final email = _emailController.text.trim();
        final phone = _phoneController.text.trim();
        final sharingAllowed = widget.canShareMedia?.call() ?? true;
        final canEmail =
            sharingSettings.mailEnabled &&
            email.isNotEmpty &&
            sharingAllowed &&
            !deliveryState.isSendingMedia;
        final canSms =
            sharingSettings.smsEnabled &&
            phone.isNotEmpty &&
            downloadUrl != null &&
            sharingAllowed &&
            !deliveryState.isSendingSms;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (sharingSettings.mailEnabled) ...[
              _GuestDeliveryField(
                controller: _emailController,
                label: 'Guest email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: canEmail
                  ? () async {
                      final sent = await widget.sharingDeliveryController
                          .sendMediaEmail(
                            settings: sharingSettings,
                            mediaFilePath: widget.state.collage!.filePath,
                            recipientEmail: email,
                          );
                      if (sent) {
                        await widget.onMediaShared?.call();
                      }
                    }
                  : null,
              icon: deliveryState.isSendingMedia
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.email_outlined),
              label: Text(
                deliveryState.isSendingMedia
                    ? widget.screenTexts.text('sendingEmail')
                    : widget.screenTexts.text('emailCollage'),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed:
                  sharingSettings.saveToPcEnabled &&
                      !deliveryState.isSavingMedia
                  ? () async {
                      final sourcePath = widget.state.collage!.filePath;
                      final location = await getSaveLocation(
                        suggestedName: File(sourcePath).uri.pathSegments.last,
                        acceptedTypeGroups: const [
                          XTypeGroup(
                            label: 'Images',
                            extensions: ['jpg', 'jpeg', 'png'],
                          ),
                        ],
                      );
                      if (location == null) {
                        return;
                      }
                      final saved = await widget.sharingDeliveryController
                          .saveMediaToPc(
                            sourcePath: sourcePath,
                            destinationPath: location.path,
                          );
                      if (saved) {
                        await widget.onMediaShared?.call();
                      }
                    }
                  : null,
              icon: deliveryState.isSavingMedia
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt_outlined),
              label: Text(
                deliveryState.isSavingMedia
                    ? widget.screenTexts.text('savingFile')
                    : widget.screenTexts.text('saveAs'),
              ),
            ),
            if (!sharingSettings.saveToPcEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(widget.screenTexts.text('saveToPcDisabled')),
              ),
            const SizedBox(height: 8),
            if (sharingSettings.smsEnabled) ...[
              _GuestDeliveryField(
                controller: _phoneController,
                label: 'Guest phone',
                icon: Icons.sms_outlined,
                keyboardType: TextInputType.phone,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: canSms
                  ? () async {
                      final sent = await widget.sharingDeliveryController
                          .sendMediaSms(
                            settings: sharingSettings,
                            downloadUrl: downloadUrl,
                            recipientPhone: phone,
                          );
                      if (sent) {
                        await widget.onMediaShared?.call();
                      }
                    }
                  : null,
              icon: deliveryState.isSendingSms
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sms_outlined),
              label: Text(
                deliveryState.isSendingSms
                    ? widget.screenTexts.text('sendingSms')
                    : widget.screenTexts.text('smsLink'),
              ),
            ),
            if (!sharingSettings.mailEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(widget.screenTexts.text('emailDisabled')),
              ),
            if (!sharingAllowed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(widget.screenTexts.text('sharingLimitReached')),
              ),
            if (!sharingSettings.smsEnabled)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(widget.screenTexts.text('smsDisabled')),
              )
            else if (downloadUrl == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(widget.screenTexts.text('qrPreparing')),
              ),
            if (deliveryState.message != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(deliveryState.message!),
              ),
            if (deliveryState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  deliveryState.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _GuestDeliveryField extends StatelessWidget {
  const _GuestDeliveryField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          isDense: true,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
