class BoothEvent {
  const BoothEvent({
    required this.id,
    required this.name,
    required this.createdAt,
    this.mediaCollected = 0,
    this.mediaShared = 0,
    this.mediaPrinted = 0,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final int mediaCollected;
  final int mediaShared;
  final int mediaPrinted;
  final bool isArchived;

  BoothEvent copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    int? mediaCollected,
    int? mediaShared,
    int? mediaPrinted,
    bool? isArchived,
  }) {
    return BoothEvent(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      mediaCollected: mediaCollected ?? this.mediaCollected,
      mediaShared: mediaShared ?? this.mediaShared,
      mediaPrinted: mediaPrinted ?? this.mediaPrinted,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class EventCatalog {
  const EventCatalog({required this.currentEvent, this.archive = const []});

  factory EventCatalog.initial({DateTime? now}) {
    final createdAt = now ?? DateTime.now();

    return EventCatalog(
      currentEvent: BoothEvent(
        id: 'event-${createdAt.microsecondsSinceEpoch}',
        name: 'New Event',
        createdAt: createdAt,
      ),
    );
  }

  final BoothEvent currentEvent;
  final List<BoothEvent> archive;

  EventCatalog copyWith({BoothEvent? currentEvent, List<BoothEvent>? archive}) {
    return EventCatalog(
      currentEvent: currentEvent ?? this.currentEvent,
      archive: archive ?? this.archive,
    );
  }
}
