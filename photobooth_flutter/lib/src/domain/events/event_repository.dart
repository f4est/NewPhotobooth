import 'booth_event.dart';

abstract interface class EventRepository {
  Future<EventCatalog> load();

  Future<void> save(EventCatalog catalog);
}
