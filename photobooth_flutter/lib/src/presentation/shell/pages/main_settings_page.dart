import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';

import '../../../domain/settings/app_settings.dart';
import '../../camera/camera_discovery_controller.dart';
import '../../settings/settings_controller.dart';
import '../shell_chrome.dart';

class MainSettingsPage extends StatelessWidget {
  const MainSettingsPage({
    required this.controller,
    required this.cameraDiscoveryController,
    super.key,
  });

  final SettingsController controller;
  final CameraDiscoveryController cameraDiscoveryController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SettingsState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final settings = state.settings;
        final selectedMode = settings.mode == BoothMode.photoAndVideo
            ? BoothMode.photo
            : settings.mode;

        return AdminPage(
          title: 'Main Settings',
          subtitle: 'Configure camera, capture flow and booth startup.',
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            AdminPanel(
              title: 'Mode Settings',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FormFieldLabel('Select Mode'),
                  SizedBox(
                    width: 360,
                    child: DropdownButtonFormField<BoothMode>(
                      initialValue: selectedMode,
                      items: const [
                        DropdownMenuItem(
                          value: BoothMode.photo,
                          child: Text('Photo Booth'),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          controller.update(settings.copyWith(mode: mode));
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Shooting Options',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Wrap(
                    spacing: 18,
                    children: [
                      OptionSwitch(
                        label: 'Photo',
                        value: settings.shooting.photoEnabled,
                        onChanged: (value) => _updateShooting(
                          settings.shooting.copyWith(photoEnabled: value),
                          settings,
                        ),
                      ),
                      OptionSwitch(label: 'Video / 360', value: false),
                      OptionSwitch(label: 'GIF', value: false),
                      OptionSwitch(
                        label: 'Gallery',
                        value: settings.shooting.galleryEnabled,
                        onChanged: (value) => _updateShooting(
                          settings.shooting.copyWith(galleryEnabled: value),
                          settings,
                        ),
                      ),
                      OptionSwitch(
                        label: 'Fullscreen Preview',
                        value: settings.shooting.fullscreenPreview,
                        onChanged: (value) => _updateShooting(
                          settings.shooting.copyWith(fullscreenPreview: value),
                          settings,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: _PhotoCountField(
                          settings: settings,
                          controller: controller,
                        ),
                      ),
                      const SizedBox(width: 28),
                      SizedBox(
                        width: 260,
                        child: _CollageLayoutField(
                          settings: settings,
                          controller: controller,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AdminPanel(
              title: 'Camera Settings',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CameraTypeField(
                      settings: settings,
                      controller: controller,
                    ),
                  ),
                  const SizedBox(width: 36),
                  Expanded(
                    child: _CameraDeviceField(
                      settings: settings,
                      controller: controller,
                      cameraDiscoveryController: cameraDiscoveryController,
                    ),
                  ),
                  const SizedBox(width: 36),
                  Expanded(
                    child: _RotationField(
                      settings: settings,
                      controller: controller,
                    ),
                  ),
                ],
              ),
            ),
            AdminPanel(
              title: 'Green Screen Settings',
              child: Align(
                alignment: Alignment.centerLeft,
                child: OptionSwitch(
                  label: 'Enable green screen compositing',
                  value: false,
                ),
              ),
            ),
            AdminPanel(
              title: 'Shooting Settings',
              child: Row(
                children: [
                  Expanded(
                    child: _LabeledInput(
                      label: 'Countdown Seconds',
                      value: settings.shooting.countdownSeconds.toString(),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => _updateShooting(
                        settings.shooting.copyWith(
                          countdownSeconds:
                              int.tryParse(value) ??
                              settings.shooting.countdownSeconds,
                        ),
                        settings,
                      ),
                    ),
                  ),
                  const SizedBox(width: 36),
                  Expanded(
                    child: OptionSwitch(
                      label: 'Mirror Preview',
                      value: settings.shooting.mirrorPreview,
                      onChanged: (value) => _updateShooting(
                        settings.shooting.copyWith(mirrorPreview: value),
                        settings,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AdminPanel(
              title: 'Output Sharing Folder',
              child: Row(
                children: [
                  Expanded(
                    child: CompactInput(
                      hint: 'C:\\Events\\Current',
                      initialValue: settings.shooting.outputFolder,
                      onChanged: (value) => _updateShooting(
                        settings.shooting.copyWith(outputFolder: value),
                        settings,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      final path = await getDirectoryPath();
                      if (path != null && path.trim().isNotEmpty) {
                        _updateShooting(
                          settings.shooting.copyWith(outputFolder: path),
                          settings,
                        );
                      }
                    },
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Select Folder'),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => _updateShooting(
                      settings.shooting.copyWith(outputFolder: ''),
                      settings,
                    ),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            AdminPanel(
              title: 'Self-Service Mode Settings',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LabeledInput(
                    label: 'Security Pin',
                    value: settings.selfService.securityPin,
                    onChanged: (value) => controller.update(
                      settings.copyWith(
                        selfService: settings.selfService.copyWith(
                          securityPin: value,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OptionSwitch(
                    label: 'Open booth mode when the application starts',
                    value: settings.selfService.runOnStartup,
                    onChanged: (value) => controller.update(
                      settings.copyWith(
                        selfService: settings.selfService.copyWith(
                          runOnStartup: value,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledInput(
                    label: 'Sharing Limit (0 = endless)',
                    value: settings.selfService.sharingLimit.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => controller.update(
                      settings.copyWith(
                        selfService: settings.selfService.copyWith(
                          sharingLimit:
                              int.tryParse(value) ??
                              settings.selfService.sharingLimit,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledInput(
                    label: 'Print Limit Each Photo (0 = endless)',
                    value: settings.selfService.printLimitEachPhoto.toString(),
                    keyboardType: TextInputType.number,
                    onChanged: (value) => controller.update(
                      settings.copyWith(
                        selfService: settings.selfService.copyWith(
                          printLimitEachPhoto:
                              int.tryParse(value) ??
                              settings.selfService.printLimitEachPhoto,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _updateShooting(ShootingSettings shooting, AppSettings settings) {
    controller.update(settings.copyWith(shooting: shooting));
  }
}

class _CameraTypeField extends StatelessWidget {
  const _CameraTypeField({required this.settings, required this.controller});

  final AppSettings settings;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormFieldLabel('Select Camera Type'),
        DropdownButtonFormField<CameraType>(
          initialValue: settings.camera.type,
          items: const [
            DropdownMenuItem(value: CameraType.webcam, child: Text('Webcam')),
            DropdownMenuItem(
              value: CameraType.canonEdsdk,
              child: Text('Canon DSLR USB'),
            ),
            DropdownMenuItem(
              value: CameraType.canonCcapi,
              child: Text('Canon CCAPI Wi-Fi'),
            ),
            DropdownMenuItem(value: CameraType.nikon, child: Text('Nikon')),
            DropdownMenuItem(value: CameraType.sony, child: Text('Sony')),
          ],
          onChanged: (type) {
            if (type != null) {
              controller.update(
                settings.copyWith(camera: settings.camera.copyWith(type: type)),
              );
            }
          },
        ),
      ],
    );
  }
}

class _RotationField extends StatelessWidget {
  const _RotationField({required this.settings, required this.controller});

  final AppSettings settings;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormFieldLabel('Camera Rotation'),
        DropdownButtonFormField<int>(
          initialValue: settings.camera.rotationDegrees,
          items: const [
            DropdownMenuItem(value: 0, child: Text('0 degrees')),
            DropdownMenuItem(value: 90, child: Text('90 degrees')),
            DropdownMenuItem(value: 180, child: Text('180 degrees')),
            DropdownMenuItem(value: 270, child: Text('270 degrees')),
          ],
          onChanged: (rotation) {
            if (rotation != null) {
              controller.update(
                settings.copyWith(
                  camera: settings.camera.copyWith(rotationDegrees: rotation),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _PhotoCountField extends StatelessWidget {
  const _PhotoCountField({required this.settings, required this.controller});

  final AppSettings settings;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormFieldLabel('Photos Per Session'),
        DropdownButtonFormField<int>(
          initialValue: settings.shooting.photoCount,
          items: const [
            DropdownMenuItem(value: 1, child: Text('1 photo')),
            DropdownMenuItem(value: 2, child: Text('2 photos')),
            DropdownMenuItem(value: 3, child: Text('3 photos')),
            DropdownMenuItem(value: 4, child: Text('4 photos')),
            DropdownMenuItem(value: 5, child: Text('5 photos')),
            DropdownMenuItem(value: 6, child: Text('6 photos')),
          ],
          onChanged: (count) {
            if (count != null) {
              controller.update(
                settings.copyWith(
                  shooting: settings.shooting.copyWith(photoCount: count),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _CollageLayoutField extends StatelessWidget {
  const _CollageLayoutField({required this.settings, required this.controller});

  final AppSettings settings;
  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormFieldLabel('Collage Layout'),
        DropdownButtonFormField<CollageLayoutPreset>(
          initialValue: settings.shooting.collageLayoutPreset,
          items: const [
            DropdownMenuItem(
              value: CollageLayoutPreset.grid,
              child: Text('Grid'),
            ),
            DropdownMenuItem(
              value: CollageLayoutPreset.stripVertical,
              child: Text('Vertical Strip'),
            ),
            DropdownMenuItem(
              value: CollageLayoutPreset.stripHorizontal,
              child: Text('Horizontal Strip'),
            ),
          ],
          onChanged: (preset) {
            if (preset != null) {
              controller.update(
                settings.copyWith(
                  shooting: settings.shooting.copyWith(
                    collageLayoutPreset: preset,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _CameraDeviceField extends StatelessWidget {
  const _CameraDeviceField({
    required this.settings,
    required this.controller,
    required this.cameraDiscoveryController,
  });

  final AppSettings settings;
  final SettingsController controller;
  final CameraDiscoveryController cameraDiscoveryController;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraDiscoveryState>(
      valueListenable: cameraDiscoveryController,
      builder: (context, state, _) {
        final cameraIds = state.cameras.map((camera) => camera.id).toSet();
        final selected = cameraIds.contains(settings.camera.cameraName)
            ? settings.camera.cameraName
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: FormFieldLabel('Select Camera')),
                IconButton(
                  tooltip: 'Refresh cameras',
                  onPressed: cameraDiscoveryController.refresh,
                  icon: const Icon(Icons.refresh, size: 18),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: selected,
              hint: Text(
                state.isLoading ? 'Loading cameras...' : 'Default camera',
              ),
              items: [
                for (final camera in state.cameras)
                  DropdownMenuItem(
                    value: camera.id,
                    child: Text(camera.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (cameraId) => controller.update(
                settings.copyWith(
                  camera: settings.camera.copyWith(cameraName: cameraId ?? ''),
                ),
              ),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 6),
              Text(
                state.error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
            if (!state.isLoading && state.cameras.isEmpty) ...[
              const SizedBox(height: 6),
              const Text(
                'No cameras found. Check Windows camera permissions.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.value,
    this.onChanged,
    this.keyboardType,
  });

  final String label;
  final String value;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label),
        CompactInput(
          initialValue: value,
          onChanged: onChanged,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
