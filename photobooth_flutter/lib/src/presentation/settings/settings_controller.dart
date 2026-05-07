import 'package:flutter/foundation.dart';

import '../../application/settings/load_settings.dart';
import '../../application/settings/save_settings.dart';
import '../../application/system/apply_startup_preference.dart';
import '../../domain/settings/app_settings.dart';

class SettingsState {
  const SettingsState({
    required this.settings,
    this.isLoading = false,
    this.hasLoaded = false,
    this.isSaving = false,
    this.message,
  });

  final AppSettings settings;
  final bool isLoading;
  final bool hasLoaded;
  final bool isSaving;
  final String? message;

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    bool? hasLoaded,
    bool? isSaving,
    String? message,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      isSaving: isSaving ?? this.isSaving,
      message: message,
    );
  }
}

class SettingsController extends ValueNotifier<SettingsState> {
  SettingsController({
    required LoadSettings loadSettings,
    required SaveSettings saveSettings,
    ApplyStartupPreference? applyStartupPreference,
  }) : _loadSettings = loadSettings,
       _saveSettings = saveSettings,
       _applyStartupPreference = applyStartupPreference,
       super(const SettingsState(settings: AppSettings()));

  final LoadSettings _loadSettings;
  final SaveSettings _saveSettings;
  final ApplyStartupPreference? _applyStartupPreference;

  Future<void> load() async {
    value = value.copyWith(isLoading: true);
    final settings = await _loadSettings();
    value = SettingsState(settings: settings, hasLoaded: true);
    final startupError = await _syncStartup(settings);
    if (startupError != null) {
      value = value.copyWith(message: startupError);
    }
  }

  Future<void> update(AppSettings settings) async {
    value = value.copyWith(settings: settings, isSaving: true);
    await _saveSettings(settings);
    final startupError = await _syncStartup(settings);
    value = value.copyWith(
      isSaving: false,
      message: startupError == null
          ? 'Settings saved'
          : 'Settings saved. $startupError',
    );
  }

  Future<String?> _syncStartup(AppSettings settings) async {
    final applyStartupPreference = _applyStartupPreference;
    if (applyStartupPreference == null) {
      return null;
    }

    try {
      await applyStartupPreference(settings.selfService.runOnStartup);
      return null;
    } catch (error) {
      return 'Windows startup sync failed: $error';
    }
  }
}
