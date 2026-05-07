import '../../domain/settings/app_settings.dart';
import '../../domain/settings/settings_repository.dart';

class SaveSettings {
  const SaveSettings({required SettingsRepository repository})
    : _repository = repository;

  final SettingsRepository _repository;

  Future<void> call(AppSettings settings) => _repository.save(settings);
}
