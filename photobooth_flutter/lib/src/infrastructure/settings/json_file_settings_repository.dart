import 'dart:convert';
import 'dart:io';

import '../../domain/settings/app_settings.dart';
import '../../domain/settings/settings_repository.dart';
import 'app_settings_json_mapper.dart';

class JsonFileSettingsRepository implements SettingsRepository {
  const JsonFileSettingsRepository({
    required File file,
    AppSettingsJsonMapper mapper = const AppSettingsJsonMapper(),
  }) : _file = file,
       _mapper = mapper;

  final File _file;
  final AppSettingsJsonMapper _mapper;

  @override
  Future<AppSettings> load() async {
    if (!await _file.exists()) {
      return const AppSettings();
    }

    final raw = await _file.readAsString();
    if (raw.trim().isEmpty) {
      return const AppSettings();
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, Object?>) {
      return const AppSettings();
    }

    return _mapper.fromJson(decoded);
  }

  @override
  Future<void> save(AppSettings settings) async {
    await _file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await _file.writeAsString(encoder.convert(_mapper.toJson(settings)));
  }
}

File defaultSettingsFile() {
  final appData = Platform.environment['APPDATA'];
  final base = appData == null || appData.isEmpty
      ? Directory.current.path
      : appData;
  return File('$base\\NewPhotobooth\\settings.json');
}
