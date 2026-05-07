import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../../domain/settings/app_settings.dart';
import '../../settings/settings_controller.dart';
import '../shell_chrome.dart';

class ScreenThemePage extends StatelessWidget {
  const ScreenThemePage({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SettingsState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final settings = state.settings;
        final theme = settings.theme;

        return AdminPage(
          title: 'Screen Theme Settings',
          subtitle:
              'Customize booth colors and the guest screen background image.',
          children: [
            AdminPanel(
              title: 'Theme Colors',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ColorSetting(
                      label: 'Action Color',
                      value: theme.themeColor,
                      onChanged: (color) =>
                          _update(settings, theme.copyWith(themeColor: color)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _ColorSetting(
                      label: 'Booth Background',
                      value: theme.homeBackgroundColor,
                      onChanged: (color) => _update(
                        settings,
                        theme.copyWith(homeBackgroundColor: color),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AdminPanel(
              title: 'Background Image',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  OptionSwitch(
                    label: 'Use Background Image',
                    value: theme.homeBackgroundImageEnabled,
                    onChanged: (value) => _update(
                      settings,
                      theme.copyWith(homeBackgroundImageEnabled: value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _PathField(
                          path: theme.backgroundImagePath,
                          onChanged: (path) => _update(
                            settings,
                            theme.copyWith(backgroundImagePath: path),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        onPressed: () => _pickBackground(settings, theme),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload Background'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: theme.backgroundImagePath.trim().isEmpty
                            ? null
                            : () => _update(
                                settings,
                                theme.copyWith(
                                  backgroundImagePath: '',
                                  homeBackgroundImageEnabled: false,
                                ),
                              ),
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _BackgroundPreview(theme: theme),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickBackground(
    AppSettings settings,
    ScreenThemeSettings theme,
  ) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Images',
          extensions: ['jpg', 'jpeg', 'png', 'webp', 'bmp'],
        ),
      ],
    );
    if (file == null) {
      return;
    }

    _update(
      settings,
      theme.copyWith(
        backgroundImagePath: file.path,
        homeBackgroundImageEnabled: true,
      ),
    );
  }

  void _update(AppSettings settings, ScreenThemeSettings theme) {
    controller.update(settings.copyWith(theme: theme));
  }
}

class _ColorSetting extends StatelessWidget {
  const _ColorSetting({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = Color(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label),
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xffcbd5e1)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CompactInput(
                initialValue: _formatColor(value),
                onChanged: (text) {
                  final parsed = _parseColor(text);
                  if (parsed != null) {
                    onChanged(parsed);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in _colorPresets)
              InkWell(
                onTap: () => onChanged(preset),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Color(preset),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xffcbd5e1)),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PathField extends StatelessWidget {
  const _PathField({required this.path, required this.onChanged});

  final String path;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormFieldLabel('Image Path'),
        CompactInput(
          initialValue: path,
          hint: 'Select JPG, PNG, WEBP or BMP file',
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _BackgroundPreview extends StatelessWidget {
  const _BackgroundPreview({required this.theme});

  final ScreenThemeSettings theme;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Color(theme.homeBackgroundColor);
    final image = File(theme.backgroundImagePath);
    final hasImage =
        theme.homeBackgroundImageEnabled &&
        theme.backgroundImagePath.trim().isNotEmpty &&
        image.existsSync();

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffe2e8f0)),
        image: hasImage
            ? DecorationImage(image: FileImage(image), fit: BoxFit.cover)
            : null,
      ),
      child: Stack(
        children: [
          if (!hasImage)
            Center(
              child: Text(
                theme.homeBackgroundImageEnabled
                    ? 'Background image file not found.'
                    : 'Background color preview',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 16,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(theme.themeColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Action Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatColor(int value) {
  return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
}

int? _parseColor(String value) {
  final normalized = value.trim().replaceFirst('#', '');
  if (normalized.length == 6) {
    return int.tryParse('FF$normalized', radix: 16);
  }
  if (normalized.length == 8) {
    return int.tryParse(normalized, radix: 16);
  }
  return null;
}

const _colorPresets = [
  0xff2563eb,
  0xff0f766e,
  0xffdc2626,
  0xffca8a04,
  0xff7c3aed,
  0xff111827,
  0xffffffff,
];
