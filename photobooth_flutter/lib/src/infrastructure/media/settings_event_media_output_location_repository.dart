import 'dart:io';

import '../../domain/events/event_repository.dart';
import '../../domain/media/media_output_location.dart';
import '../../domain/media/media_output_location_repository.dart';
import '../../domain/settings/settings_repository.dart';

class SettingsEventMediaOutputLocationRepository
    implements MediaOutputLocationRepository {
  const SettingsEventMediaOutputLocationRepository({
    required SettingsRepository settingsRepository,
    required EventRepository eventRepository,
  }) : _settingsRepository = settingsRepository,
       _eventRepository = eventRepository;

  final SettingsRepository _settingsRepository;
  final EventRepository _eventRepository;

  @override
  Future<MediaOutputLocation> current() async {
    final settings = await _settingsRepository.load();
    final events = await _eventRepository.load();

    return MediaOutputLocation(
      baseFolder: settings.shooting.outputFolder.trim().isEmpty
          ? _defaultMediaFolder()
          : settings.shooting.outputFolder.trim(),
      eventName: events.currentEvent.name,
    );
  }

  String _defaultMediaFolder() {
    final pictures = Platform.environment['USERPROFILE'];
    final base = pictures == null || pictures.isEmpty
        ? Directory.current.path
        : '$pictures\\Pictures';
    return '$base\\NewPhotobooth';
  }
}
