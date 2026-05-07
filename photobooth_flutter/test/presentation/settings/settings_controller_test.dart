import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/application/settings/load_settings.dart';
import 'package:photobooth_flutter/src/application/settings/save_settings.dart';
import 'package:photobooth_flutter/src/application/system/apply_startup_preference.dart';
import 'package:photobooth_flutter/src/domain/settings/app_settings.dart';
import 'package:photobooth_flutter/src/domain/settings/settings_repository.dart';
import 'package:photobooth_flutter/src/domain/system/startup_repository.dart';
import 'package:photobooth_flutter/src/presentation/settings/settings_controller.dart';

void main() {
  test('syncs Windows startup preference when settings are updated', () async {
    final settingsRepository = _FakeSettingsRepository();
    final startupRepository = _FakeStartupRepository();
    final controller = SettingsController(
      loadSettings: LoadSettings(repository: settingsRepository),
      saveSettings: SaveSettings(repository: settingsRepository),
      applyStartupPreference: ApplyStartupPreference(
        repository: startupRepository,
      ),
    );

    await controller.update(
      const AppSettings(selfService: SelfServiceSettings(runOnStartup: true)),
    );

    expect(settingsRepository.saved.selfService.runOnStartup, isTrue);
    expect(startupRepository.lastEnabled, isTrue);
    expect(controller.value.message, 'Settings saved');
  });

  test('keeps settings saved when startup sync fails', () async {
    final settingsRepository = _FakeSettingsRepository();
    final startupRepository = _FakeStartupRepository(shouldThrow: true);
    final controller = SettingsController(
      loadSettings: LoadSettings(repository: settingsRepository),
      saveSettings: SaveSettings(repository: settingsRepository),
      applyStartupPreference: ApplyStartupPreference(
        repository: startupRepository,
      ),
    );

    await controller.update(
      const AppSettings(selfService: SelfServiceSettings(runOnStartup: true)),
    );

    expect(settingsRepository.saved.selfService.runOnStartup, isTrue);
    expect(controller.value.message, contains('startup sync failed'));
  });
}

class _FakeSettingsRepository implements SettingsRepository {
  AppSettings saved = const AppSettings();

  @override
  Future<AppSettings> load() async => saved;

  @override
  Future<void> save(AppSettings settings) async {
    saved = settings;
  }
}

class _FakeStartupRepository implements StartupRepository {
  _FakeStartupRepository({this.shouldThrow = false});

  final bool shouldThrow;
  bool? lastEnabled;

  @override
  Future<void> setRunOnStartup(bool enabled) async {
    lastEnabled = enabled;
    if (shouldThrow) {
      throw StateError('denied');
    }
  }
}
