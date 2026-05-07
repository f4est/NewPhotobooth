import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/infrastructure/system/windows_startup_repository.dart';

void main() {
  test('builds a Windows startup shortcut command', () {
    const command = WindowsStartupShortcutCommand(
      shortcutPath: r'C:\Users\User\AppData\Startup\NewPhotobooth.lnk',
      executablePath: r'C:\Program Files\NewPhotobooth\photobooth.exe',
      appName: 'NewPhotobooth',
    );

    final script = _decodeUtf16Le(base64Decode(command.arguments.last));

    expect(command.executable, 'powershell');
    expect(command.arguments, contains('-EncodedCommand'));
    expect(script, contains('WScript.Shell'));
    expect(script, contains('CreateShortcut'));
    expect(script, contains(r'C:\Program Files\NewPhotobooth\photobooth.exe'));
  });
}

String _decodeUtf16Le(List<int> bytes) {
  final units = <int>[];
  for (var index = 0; index < bytes.length; index += 2) {
    units.add(bytes[index] | (bytes[index + 1] << 8));
  }
  return String.fromCharCodes(units);
}
