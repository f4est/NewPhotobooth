import 'package:flutter/foundation.dart';

import '../../application/events/load_events.dart';
import '../../application/events/save_events.dart';
import '../../domain/events/booth_event.dart';

class EventState {
  const EventState({
    required this.catalog,
    this.isLoading = false,
    this.isSaving = false,
    this.message,
  });

  factory EventState.initial() {
    return EventState(catalog: EventCatalog.initial());
  }

  final EventCatalog catalog;
  final bool isLoading;
  final bool isSaving;
  final String? message;

  EventState copyWith({
    EventCatalog? catalog,
    bool? isLoading,
    bool? isSaving,
    String? message,
  }) {
    return EventState(
      catalog: catalog ?? this.catalog,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      message: message,
    );
  }
}

class EventController extends ValueNotifier<EventState> {
  EventController({
    required LoadEvents loadEvents,
    required SaveEvents saveEvents,
  }) : _loadEvents = loadEvents,
       _saveEvents = saveEvents,
       super(EventState.initial());

  final LoadEvents _loadEvents;
  final SaveEvents _saveEvents;

  Future<void> load() async {
    value = value.copyWith(isLoading: true);
    final catalog = await _loadEvents();
    value = EventState(catalog: catalog);
  }

  Future<void> renameCurrentEvent(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await _saveCatalog(
      value.catalog.copyWith(
        currentEvent: value.catalog.currentEvent.copyWith(name: trimmed),
      ),
      message: 'Event renamed',
    );
  }

  Future<void> closeAndStartNewEvent({String name = 'New Event'}) async {
    final now = DateTime.now();
    final archivedCurrent = value.catalog.currentEvent.copyWith(
      isArchived: true,
    );
    final next = BoothEvent(
      id: 'event-${now.microsecondsSinceEpoch}',
      name: name,
      createdAt: now,
    );

    await _saveCatalog(
      EventCatalog(
        currentEvent: next,
        archive: [archivedCurrent, ...value.catalog.archive],
      ),
      message: 'New event started',
    );
  }

  Future<void> copyCurrentEvent() async {
    final now = DateTime.now();
    await _saveCatalog(
      value.catalog.copyWith(
        currentEvent: value.catalog.currentEvent.copyWith(
          id: 'event-${now.microsecondsSinceEpoch}',
          name: '${value.catalog.currentEvent.name} Copy',
          createdAt: now,
          mediaCollected: 0,
          mediaShared: 0,
          mediaPrinted: 0,
          isArchived: false,
        ),
      ),
      message: 'Event copied',
    );
  }

  Future<void> reuseArchivedEvent(String eventId) async {
    final archive = value.catalog.archive;
    final index = archive.indexWhere((event) => event.id == eventId);
    if (index == -1) {
      return;
    }

    final selected = archive[index].copyWith(isArchived: false);
    final archivedCurrent = value.catalog.currentEvent.copyWith(
      isArchived: true,
    );
    final nextArchive = [
      archivedCurrent,
      for (var i = 0; i < archive.length; i += 1)
        if (i != index) archive[i],
    ];

    await _saveCatalog(
      EventCatalog(currentEvent: selected, archive: nextArchive),
      message: 'Archived event reused',
    );
  }

  Future<void> incrementCollected() async {
    await _saveCatalog(
      value.catalog.copyWith(
        currentEvent: value.catalog.currentEvent.copyWith(
          mediaCollected: value.catalog.currentEvent.mediaCollected + 1,
        ),
      ),
    );
  }

  Future<void> incrementPrinted() async {
    await _saveCatalog(
      value.catalog.copyWith(
        currentEvent: value.catalog.currentEvent.copyWith(
          mediaPrinted: value.catalog.currentEvent.mediaPrinted + 1,
        ),
      ),
    );
  }

  Future<void> incrementShared() async {
    await _saveCatalog(
      value.catalog.copyWith(
        currentEvent: value.catalog.currentEvent.copyWith(
          mediaShared: value.catalog.currentEvent.mediaShared + 1,
        ),
      ),
    );
  }

  Future<void> _saveCatalog(EventCatalog catalog, {String? message}) async {
    value = value.copyWith(catalog: catalog, isSaving: true);
    await _saveEvents(catalog);
    value = value.copyWith(isSaving: false, message: message);
  }
}
