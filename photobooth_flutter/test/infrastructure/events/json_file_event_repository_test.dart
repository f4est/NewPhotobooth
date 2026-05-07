import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/domain/events/booth_event.dart';
import 'package:photobooth_flutter/src/infrastructure/events/json_file_event_repository.dart';

void main() {
  test('load returns an initial event when the file is missing', () async {
    final directory = await Directory.systemTemp.createTemp('events_test');
    addTearDown(() => directory.delete(recursive: true));
    final repository = JsonFileEventRepository(
      file: File('${directory.path}\\missing.json'),
    );

    final catalog = await repository.load();

    expect(catalog.currentEvent.name, 'New Event');
    expect(catalog.archive, isEmpty);
  });

  test('save and load round trips current event and archive', () async {
    final directory = await Directory.systemTemp.createTemp('events_test');
    addTearDown(() => directory.delete(recursive: true));
    final repository = JsonFileEventRepository(
      file: File('${directory.path}\\events.json'),
    );
    final catalog = EventCatalog(
      currentEvent: BoothEvent(
        id: 'event-current',
        name: 'Wedding',
        createdAt: DateTime(2026, 5, 6),
        mediaCollected: 3,
      ),
      archive: [
        BoothEvent(
          id: 'event-old',
          name: 'Archive',
          createdAt: DateTime(2026, 5, 1),
          isArchived: true,
        ),
      ],
    );

    await repository.save(catalog);
    final loaded = await repository.load();

    expect(loaded.currentEvent.id, 'event-current');
    expect(loaded.currentEvent.name, 'Wedding');
    expect(loaded.currentEvent.mediaCollected, 3);
    expect(loaded.archive.single.id, 'event-old');
    expect(loaded.archive.single.isArchived, isTrue);
  });
}
