import '../../domain/events/booth_event.dart';

class EventCatalogJsonMapper {
  const EventCatalogJsonMapper();

  Map<String, Object?> toJson(EventCatalog catalog) {
    return {
      'currentEvent': _eventToJson(catalog.currentEvent),
      'archive': catalog.archive.map(_eventToJson).toList(),
    };
  }

  EventCatalog fromJson(Map<String, Object?> json) {
    final current = _map(json['currentEvent']);
    final archive = json['archive'];

    return EventCatalog(
      currentEvent: _eventFromJson(current),
      archive: archive is List
          ? archive.map(_map).map(_eventFromJson).toList(growable: false)
          : const [],
    );
  }

  Map<String, Object?> _eventToJson(BoothEvent event) {
    return {
      'id': event.id,
      'name': event.name,
      'createdAt': event.createdAt.toIso8601String(),
      'mediaCollected': event.mediaCollected,
      'mediaShared': event.mediaShared,
      'mediaPrinted': event.mediaPrinted,
      'isArchived': event.isArchived,
    };
  }

  BoothEvent _eventFromJson(Map<String, Object?> json) {
    final now = DateTime.now();
    return BoothEvent(
      id: _string(json['id'], 'event-${now.microsecondsSinceEpoch}'),
      name: _string(json['name'], 'New Event'),
      createdAt: DateTime.tryParse(_string(json['createdAt'], '')) ?? now,
      mediaCollected: _int(json['mediaCollected'], 0),
      mediaShared: _int(json['mediaShared'], 0),
      mediaPrinted: _int(json['mediaPrinted'], 0),
      isArchived: _bool(json['isArchived'], false),
    );
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  String _string(Object? value, String fallback) {
    return value is String ? value : fallback;
  }

  int _int(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  bool _bool(Object? value, bool fallback) {
    return value is bool ? value : fallback;
  }
}
