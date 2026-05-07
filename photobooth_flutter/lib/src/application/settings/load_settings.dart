import '../../domain/settings/app_settings.dart';
import '../../domain/settings/settings_repository.dart';

class LoadSettings {
  const LoadSettings({required SettingsRepository repository})
    : _repository = repository;

  final SettingsRepository _repository;

  Future<AppSettings> call() => _repository.load();
}
