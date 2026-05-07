import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/domain/settings/app_settings.dart';
import 'package:photobooth_flutter/src/infrastructure/settings/json_file_settings_repository.dart';

void main() {
  test('load returns defaults when settings file does not exist', () async {
    final directory = await Directory.systemTemp.createTemp('settings_test');
    addTearDown(() => directory.delete(recursive: true));
    final repository = JsonFileSettingsRepository(
      file: File('${directory.path}\\missing.json'),
    );

    final settings = await repository.load();

    expect(settings.shooting.photoEnabled, isTrue);
    expect(settings.sharing.qrEnabled, isTrue);
    expect(settings.print.enabled, isTrue);
  });

  test('save and load round trips changed settings', () async {
    final directory = await Directory.systemTemp.createTemp('settings_test');
    addTearDown(() => directory.delete(recursive: true));
    final repository = JsonFileSettingsRepository(
      file: File('${directory.path}\\settings.json'),
    );
    final settings = const AppSettings().copyWith(
      camera: const CameraSettings(
        type: CameraType.canonEdsdk,
        cameraName: 'Canon EOS R',
        rotationDegrees: 90,
      ),
      shooting: const ShootingSettings(
        photoCount: 3,
        collageLayoutPreset: CollageLayoutPreset.stripVertical,
        countdownSeconds: 7,
        mirrorPreview: true,
        outputFolder: 'C:\\Events',
      ),
      print: const PrintSettings(selectedPrinter: 'DNP RX1', printLimit: 2),
      screenTexts: const ScreenTextSettings().copyWithValues({
        'startSession': 'Начать',
        'printCollage': 'Печатать',
      }),
    );

    await repository.save(settings);
    final loaded = await repository.load();

    expect(loaded.camera.type, CameraType.canonEdsdk);
    expect(loaded.camera.cameraName, 'Canon EOS R');
    expect(loaded.camera.rotationDegrees, 90);
    expect(loaded.shooting.photoCount, 3);
    expect(
      loaded.shooting.collageLayoutPreset,
      CollageLayoutPreset.stripVertical,
    );
    expect(loaded.shooting.countdownSeconds, 7);
    expect(loaded.shooting.mirrorPreview, isTrue);
    expect(loaded.shooting.outputFolder, 'C:\\Events');
    expect(loaded.print.selectedPrinter, 'DNP RX1');
    expect(loaded.print.printLimit, 2);
    expect(loaded.print.paperSize, PrintPaperSize.sixByFour);
    expect(loaded.print.scaleMode, PrintScaleMode.fill);
    expect(loaded.screenTexts.text('startSession'), 'Начать');
    expect(loaded.screenTexts.text('printCollage'), 'Печатать');
    expect(loaded.screenTexts.text('gallery'), 'Gallery');
  });
}
