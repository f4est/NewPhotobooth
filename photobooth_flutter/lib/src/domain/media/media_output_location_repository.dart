import 'media_output_location.dart';

abstract interface class MediaOutputLocationRepository {
  Future<MediaOutputLocation> current();
}
