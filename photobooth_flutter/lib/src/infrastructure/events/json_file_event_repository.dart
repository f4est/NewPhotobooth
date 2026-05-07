import 'dart:convert';
import 'dart:io';

import '../../domain/events/booth_event.dart';
import '../../domain/events/event_repository.dart';
import 'event_catalog_json_mapper.dart';

class JsonFileEventRepository implements EventRepository {
  const JsonFileEventRepository({
    required File file,
    EventCatalogJsonMapper mapper = const EventCatalogJsonMapper(),
  }) : _file = file,
       _mapper = mapper;

  final File _file;
  final EventCatalogJsonMapper _mapper;

  @override
  Future<EventCatalog> load() async {
    if (!await _file.exists()) {
      return EventCatalog.initial();
    }

    final raw = await _file.readAsString();
    if (raw.trim().isEmpty) {
      return EventCatalog.initial();
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return EventCatalog.initial();
    }

    return _mapper.fromJson(decoded);
  }

  @override
  Future<void> save(EventCatalog catalog) async {
    await _file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await _file.writeAsString(encoder.convert(_mapper.toJson(catalog)));
  }
}

File defaultEventsFile() {
  final appData = Platform.environment['APPDATA'];
  final base = appData == null || appData.isEmpty
      ? Directory.current.path
      : appData;
  return File('$base\\NewPhotobooth\\events.json');
}
