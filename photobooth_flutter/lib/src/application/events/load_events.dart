import '../../domain/events/booth_event.dart';
import '../../domain/events/event_repository.dart';

class LoadEvents {
  const LoadEvents({required EventRepository repository})
    : _repository = repository;

  final EventRepository _repository;

  Future<EventCatalog> call() => _repository.load();
}
