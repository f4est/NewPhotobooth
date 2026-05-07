import '../../domain/settings/app_settings.dart';

class AppSettingsJsonMapper {
  const AppSettingsJsonMapper();

  Map<String, Object?> toJson(AppSettings settings) {
    return {
      'mode': settings.mode.name,
      'camera': {
        'type': settings.camera.type.name,
        'cameraName': settings.camera.cameraName,
        'rotationDegrees': settings.camera.rotationDegrees,
      },
      'shooting': {
        'photoEnabled': settings.shooting.photoEnabled,
        'videoEnabled': settings.shooting.videoEnabled,
        'gifEnabled': settings.shooting.gifEnabled,
        'galleryEnabled': settings.shooting.galleryEnabled,
        'fullscreenPreview': settings.shooting.fullscreenPreview,
        'photoCount': settings.shooting.photoCount,
        'collageLayoutPreset': settings.shooting.collageLayoutPreset.name,
        'countdownSeconds': settings.shooting.countdownSeconds,
        'mirrorPreview': settings.shooting.mirrorPreview,
        'greenScreenEnabled': settings.shooting.greenScreenEnabled,
        'outputFolder': settings.shooting.outputFolder,
      },
      'sharing': {
        'mailEnabled': settings.sharing.mailEnabled,
        'smsEnabled': settings.sharing.smsEnabled,
        'qrEnabled': settings.sharing.qrEnabled,
        'saveToPcEnabled': settings.sharing.saveToPcEnabled,
        'senderEmail': settings.sharing.senderEmail,
        'senderPassword': settings.sharing.senderPassword,
        'mailBody': settings.sharing.mailBody,
        'mailSubject': settings.sharing.mailSubject,
        'smtpHost': settings.sharing.smtpHost,
        'smtpPort': settings.sharing.smtpPort,
        'receiverEmail': settings.sharing.receiverEmail,
        'smsAuthToken': settings.sharing.smsAuthToken,
        'smsSid': settings.sharing.smsSid,
        'smsFromNumber': settings.sharing.smsFromNumber,
        'smsTestNumber': settings.sharing.smsTestNumber,
      },
      'print': {
        'enabled': settings.print.enabled,
        'silentPrint': settings.print.silentPrint,
        'onePrintPerPhoto': settings.print.onePrintPerPhoto,
        'useWindowsSettings': settings.print.useWindowsSettings,
        'forceLandscape': settings.print.forceLandscape,
        'forcePortrait': settings.print.forcePortrait,
        'paperSize': settings.print.paperSize.name,
        'scaleMode': settings.print.scaleMode.name,
        'selectedPrinter': settings.print.selectedPrinter,
        'printLimit': settings.print.printLimit,
        'offsetTop': settings.print.offsetTop,
        'offsetRight': settings.print.offsetRight,
        'offsetBottom': settings.print.offsetBottom,
        'offsetLeft': settings.print.offsetLeft,
      },
      'selfService': {
        'securityPin': settings.selfService.securityPin,
        'runOnStartup': settings.selfService.runOnStartup,
        'sharingLimit': settings.selfService.sharingLimit,
        'printLimitEachPhoto': settings.selfService.printLimitEachPhoto,
      },
      'screenTexts': settings.screenTexts.values,
      'theme': {
        'themeColor': settings.theme.themeColor,
        'homeBackgroundColor': settings.theme.homeBackgroundColor,
        'backgroundImagePath': settings.theme.backgroundImagePath,
        'homeBackgroundImageEnabled': settings.theme.homeBackgroundImageEnabled,
      },
    };
  }

  AppSettings fromJson(Map<String, Object?> json) {
    final defaults = const AppSettings();
    final camera = _map(json['camera']);
    final shooting = _map(json['shooting']);
    final sharing = _map(json['sharing']);
    final print = _map(json['print']);
    final selfService = _map(json['selfService']);
    final theme = _map(json['theme']);

    return AppSettings(
      mode: _enumValue(BoothMode.values, json['mode'], defaults.mode),
      camera: CameraSettings(
        type: _enumValue(
          CameraType.values,
          camera['type'],
          defaults.camera.type,
        ),
        cameraName: _string(camera['cameraName'], defaults.camera.cameraName),
        rotationDegrees: _int(
          camera['rotationDegrees'],
          defaults.camera.rotationDegrees,
        ),
      ),
      shooting: ShootingSettings(
        photoEnabled: _bool(shooting['photoEnabled'], true),
        videoEnabled: _bool(shooting['videoEnabled'], false),
        gifEnabled: _bool(shooting['gifEnabled'], false),
        galleryEnabled: _bool(shooting['galleryEnabled'], true),
        fullscreenPreview: _bool(shooting['fullscreenPreview'], false),
        photoCount: _int(shooting['photoCount'], 4),
        collageLayoutPreset: _enumValue(
          CollageLayoutPreset.values,
          shooting['collageLayoutPreset'],
          CollageLayoutPreset.grid,
        ),
        countdownSeconds: _int(shooting['countdownSeconds'], 5),
        mirrorPreview: _bool(shooting['mirrorPreview'], false),
        greenScreenEnabled: _bool(shooting['greenScreenEnabled'], false),
        outputFolder: _string(shooting['outputFolder'], ''),
      ),
      sharing: SharingSettings(
        mailEnabled: _bool(sharing['mailEnabled'], false),
        smsEnabled: _bool(sharing['smsEnabled'], false),
        qrEnabled: _bool(sharing['qrEnabled'], true),
        saveToPcEnabled: _bool(sharing['saveToPcEnabled'], true),
        senderEmail: _string(sharing['senderEmail'], ''),
        senderPassword: _string(sharing['senderPassword'], ''),
        mailBody: _string(sharing['mailBody'], ''),
        mailSubject: _string(sharing['mailSubject'], ''),
        smtpHost: _string(sharing['smtpHost'], ''),
        smtpPort: _int(sharing['smtpPort'], 587),
        receiverEmail: _string(sharing['receiverEmail'], ''),
        smsAuthToken: _string(sharing['smsAuthToken'], ''),
        smsSid: _string(sharing['smsSid'], ''),
        smsFromNumber: _string(sharing['smsFromNumber'], ''),
        smsTestNumber: _string(sharing['smsTestNumber'], ''),
      ),
      print: PrintSettings(
        enabled: _bool(print['enabled'], true),
        silentPrint: _bool(print['silentPrint'], true),
        onePrintPerPhoto: _bool(print['onePrintPerPhoto'], false),
        useWindowsSettings: _bool(print['useWindowsSettings'], false),
        forceLandscape: _bool(print['forceLandscape'], false),
        forcePortrait: _bool(print['forcePortrait'], false),
        paperSize: _enumValue(
          PrintPaperSize.values,
          print['paperSize'],
          PrintPaperSize.sixByFour,
        ),
        scaleMode: _enumValue(
          PrintScaleMode.values,
          print['scaleMode'],
          PrintScaleMode.fill,
        ),
        selectedPrinter: _string(print['selectedPrinter'], ''),
        printLimit: _int(print['printLimit'], 1),
        offsetTop: _double(print['offsetTop'], 0),
        offsetRight: _double(print['offsetRight'], 0),
        offsetBottom: _double(print['offsetBottom'], 0),
        offsetLeft: _double(print['offsetLeft'], 0),
      ),
      selfService: SelfServiceSettings(
        securityPin: _string(selfService['securityPin'], ''),
        runOnStartup: _bool(selfService['runOnStartup'], false),
        sharingLimit: _int(selfService['sharingLimit'], 0),
        printLimitEachPhoto: _int(selfService['printLimitEachPhoto'], 0),
      ),
      screenTexts: ScreenTextSettings(values: _stringMap(json['screenTexts'])),
      theme: ScreenThemeSettings(
        themeColor: _int(theme['themeColor'], defaults.theme.themeColor),
        homeBackgroundColor: _int(
          theme['homeBackgroundColor'],
          defaults.theme.homeBackgroundColor,
        ),
        backgroundImagePath: _string(theme['backgroundImagePath'], ''),
        homeBackgroundImageEnabled: _bool(
          theme['homeBackgroundImageEnabled'],
          false,
        ),
      ),
    );
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  T _enumValue<T extends Enum>(List<T> values, Object? name, T fallback) {
    if (name is! String) {
      return fallback;
    }
    return values.where((value) => value.name == name).firstOrNull ?? fallback;
  }

  bool _bool(Object? value, bool fallback) => value is bool ? value : fallback;

  int _int(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return fallback;
  }

  double _double(Object? value, double fallback) {
    if (value is num) {
      return value.toDouble();
    }
    return fallback;
  }

  String _string(Object? value, String fallback) {
    return value is String ? value : fallback;
  }

  Map<String, String> _stringMap(Object? value) {
    final raw = _map(value);
    return {
      ...ScreenTextSettings.defaultValues,
      for (final entry in raw.entries)
        if (entry.value is String) entry.key: entry.value! as String,
    };
  }
}
