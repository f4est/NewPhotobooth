import 'dart:convert';
import 'dart:io';

import '../../domain/system/startup_repository.dart';

typedef ProcessRunner =
    Future<ProcessResult> Function(String executable, List<String> arguments);

class WindowsStartupRepository implements StartupRepository {
  WindowsStartupRepository({
    ProcessRunner? processRunner,
    String? appName,
    String? executablePath,
    Directory? startupDirectory,
  }) : _processRunner = processRunner ?? Process.run,
       _appName = appName ?? 'NewPhotobooth',
       _executablePath = executablePath ?? Platform.resolvedExecutable,
       _startupDirectory = startupDirectory ?? _defaultStartupDirectory();

  final ProcessRunner _processRunner;
  final String _appName;
  final String _executablePath;
  final Directory _startupDirectory;

  File get shortcutFile => File('${_startupDirectory.path}\\$_appName.lnk');

  @override
  Future<void> setRunOnStartup(bool enabled) async {
    if (!Platform.isWindows) {
      return;
    }

    if (enabled) {
      await _startupDirectory.create(recursive: true);
      await _createShortcut();
      return;
    }

    final file = shortcutFile;
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> _createShortcut() async {
    final command = WindowsStartupShortcutCommand(
      shortcutPath: shortcutFile.path,
      executablePath: _executablePath,
      appName: _appName,
    );
    final result = await _processRunner(command.executable, command.arguments);
    if (result.exitCode != 0) {
      throw StateError(
        'Startup shortcut command failed (${result.exitCode}): '
        '${result.stderr}',
      );
    }
  }

  static Directory _defaultStartupDirectory() {
    final appData = Platform.environment['APPDATA'];
    if (appData == null || appData.trim().isEmpty) {
      return Directory.current;
    }
    return Directory(
      '$appData\\Microsoft\\Windows\\Start Menu\\Programs\\Startup',
    );
  }
}

class WindowsStartupShortcutCommand {
  const WindowsStartupShortcutCommand({
    required this.shortcutPath,
    required this.executablePath,
    required this.appName,
  });

  final String shortcutPath;
  final String executablePath;
  final String appName;

  String get executable => 'powershell';

  List<String> get arguments => [
    '-NoProfile',
    '-ExecutionPolicy',
    'Bypass',
    '-EncodedCommand',
    base64Encode(utf16le.encode(_script)),
  ];

  String get _script {
    return '''
\$shell = New-Object -ComObject WScript.Shell
\$shortcut = \$shell.CreateShortcut('${_ps(shortcutPath)}')
\$shortcut.TargetPath = '${_ps(executablePath)}'
\$shortcut.WorkingDirectory = '${_ps(File(executablePath).parent.path)}'
\$shortcut.Description = '${_ps(appName)} booth startup'
\$shortcut.Save()
''';
  }

  String _ps(String value) => value.replaceAll("'", "''");
}

class _Utf16LeCodec extends Encoding {
  const _Utf16LeCodec();

  @override
  Converter<List<int>, String> get decoder => throw UnimplementedError();

  @override
  Converter<String, List<int>> get encoder => const _Utf16LeEncoder();

  @override
  String get name => 'utf-16le';
}

class _Utf16LeEncoder extends Converter<String, List<int>> {
  const _Utf16LeEncoder();

  @override
  List<int> convert(String input) {
    final bytes = <int>[];
    for (final codeUnit in input.codeUnits) {
      bytes.add(codeUnit & 0xff);
      bytes.add((codeUnit >> 8) & 0xff);
    }
    return bytes;
  }
}

const utf16le = _Utf16LeCodec();
