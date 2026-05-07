import '../../domain/system/startup_repository.dart';

class ApplyStartupPreference {
  const ApplyStartupPreference({required StartupRepository repository})
    : _repository = repository;

  final StartupRepository _repository;

  Future<void> call(bool enabled) => _repository.setRunOnStartup(enabled);
}
