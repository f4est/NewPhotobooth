import '../../domain/events/booth_event.dart';
import '../../domain/events/event_repository.dart';

class SaveEvents {
  const SaveEvents({required EventRepository repository})
    : _repository = repository;

  final EventRepository _repository;

  Future<void> call(EventCatalog catalog) => _repository.save(catalog);
}
