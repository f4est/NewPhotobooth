class AppSettings {
  const AppSettings({
    this.mode = BoothMode.photo,
    this.camera = const CameraSettings(),
    this.shooting = const ShootingSettings(),
    this.sharing = const SharingSettings(),
    this.print = const PrintSettings(),
    this.selfService = const SelfServiceSettings(),
    this.screenTexts = const ScreenTextSettings(),
    this.theme = const ScreenThemeSettings(),
  });

  final BoothMode mode;
  final CameraSettings camera;
  final ShootingSettings shooting;
  final SharingSettings sharing;
  final PrintSettings print;
  final SelfServiceSettings selfService;
  final ScreenTextSettings screenTexts;
  final ScreenThemeSettings theme;

  AppSettings copyWith({
    BoothMode? mode,
    CameraSettings? camera,
    ShootingSettings? shooting,
    SharingSettings? sharing,
    PrintSettings? print,
    SelfServiceSettings? selfService,
    ScreenTextSettings? screenTexts,
    ScreenThemeSettings? theme,
  }) {
    return AppSettings(
      mode: mode ?? this.mode,
      camera: camera ?? this.camera,
      shooting: shooting ?? this.shooting,
      sharing: sharing ?? this.sharing,
      print: print ?? this.print,
      selfService: selfService ?? this.selfService,
      screenTexts: screenTexts ?? this.screenTexts,
      theme: theme ?? this.theme,
    );
  }
}

enum BoothMode { photo, photoAndVideo }

enum CameraType { webcam, canonEdsdk, canonCcapi, nikon, sony }

enum CollageLayoutPreset { grid, stripVertical, stripHorizontal }

enum PrintPaperSize {
  fourBySix,
  sixByFour,
  fiveBySeven,
  sevenByFive,
  sixByEight,
  eightBySix,
  twoBySixStrip,
  sixByTwoStrip,
  a4Portrait,
  a4Landscape,
}

extension PrintPaperSizeDetails on PrintPaperSize {
  String get label {
    return switch (this) {
      PrintPaperSize.fourBySix => '4 x 6 in',
      PrintPaperSize.sixByFour => '6 x 4 in',
      PrintPaperSize.fiveBySeven => '5 x 7 in',
      PrintPaperSize.sevenByFive => '7 x 5 in',
      PrintPaperSize.sixByEight => '6 x 8 in',
      PrintPaperSize.eightBySix => '8 x 6 in',
      PrintPaperSize.twoBySixStrip => '2 x 6 strip',
      PrintPaperSize.sixByTwoStrip => '6 x 2 strip',
      PrintPaperSize.a4Portrait => 'A4 portrait',
      PrintPaperSize.a4Landscape => 'A4 landscape',
    };
  }

  double get widthInches {
    return switch (this) {
      PrintPaperSize.fourBySix => 4,
      PrintPaperSize.sixByFour => 6,
      PrintPaperSize.fiveBySeven => 5,
      PrintPaperSize.sevenByFive => 7,
      PrintPaperSize.sixByEight => 6,
      PrintPaperSize.eightBySix => 8,
      PrintPaperSize.twoBySixStrip => 2,
      PrintPaperSize.sixByTwoStrip => 6,
      PrintPaperSize.a4Portrait => 8.27,
      PrintPaperSize.a4Landscape => 11.69,
    };
  }

  double get heightInches {
    return switch (this) {
      PrintPaperSize.fourBySix => 6,
      PrintPaperSize.sixByFour => 4,
      PrintPaperSize.fiveBySeven => 7,
      PrintPaperSize.sevenByFive => 5,
      PrintPaperSize.sixByEight => 8,
      PrintPaperSize.eightBySix => 6,
      PrintPaperSize.twoBySixStrip => 6,
      PrintPaperSize.sixByTwoStrip => 2,
      PrintPaperSize.a4Portrait => 11.69,
      PrintPaperSize.a4Landscape => 8.27,
    };
  }

  bool get isLandscape => widthInches > heightInches;
}

enum PrintScaleMode { fit, fill }

class CameraSettings {
  const CameraSettings({
    this.type = CameraType.webcam,
    this.cameraName = '',
    this.rotationDegrees = 0,
  }) : assert(
         rotationDegrees == 0 ||
             rotationDegrees == 90 ||
             rotationDegrees == 180 ||
             rotationDegrees == 270,
       );

  final CameraType type;
  final String cameraName;
  final int rotationDegrees;

  CameraSettings copyWith({
    CameraType? type,
    String? cameraName,
    int? rotationDegrees,
  }) {
    return CameraSettings(
      type: type ?? this.type,
      cameraName: cameraName ?? this.cameraName,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
    );
  }
}

class ShootingSettings {
  const ShootingSettings({
    this.photoEnabled = true,
    this.videoEnabled = false,
    this.gifEnabled = false,
    this.galleryEnabled = true,
    this.fullscreenPreview = false,
    this.photoCount = 4,
    this.collageLayoutPreset = CollageLayoutPreset.grid,
    this.countdownSeconds = 5,
    this.mirrorPreview = false,
    this.greenScreenEnabled = false,
    this.outputFolder = '',
  }) : assert(photoCount > 0),
       assert(photoCount <= 6),
       assert(countdownSeconds >= 0);

  final bool photoEnabled;
  final bool videoEnabled;
  final bool gifEnabled;
  final bool galleryEnabled;
  final bool fullscreenPreview;
  final int photoCount;
  final CollageLayoutPreset collageLayoutPreset;
  final int countdownSeconds;
  final bool mirrorPreview;
  final bool greenScreenEnabled;
  final String outputFolder;

  ShootingSettings copyWith({
    bool? photoEnabled,
    bool? videoEnabled,
    bool? gifEnabled,
    bool? galleryEnabled,
    bool? fullscreenPreview,
    int? photoCount,
    CollageLayoutPreset? collageLayoutPreset,
    int? countdownSeconds,
    bool? mirrorPreview,
    bool? greenScreenEnabled,
    String? outputFolder,
  }) {
    return ShootingSettings(
      photoEnabled: photoEnabled ?? this.photoEnabled,
      videoEnabled: videoEnabled ?? this.videoEnabled,
      gifEnabled: gifEnabled ?? this.gifEnabled,
      galleryEnabled: galleryEnabled ?? this.galleryEnabled,
      fullscreenPreview: fullscreenPreview ?? this.fullscreenPreview,
      photoCount: photoCount ?? this.photoCount,
      collageLayoutPreset: collageLayoutPreset ?? this.collageLayoutPreset,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      mirrorPreview: mirrorPreview ?? this.mirrorPreview,
      greenScreenEnabled: greenScreenEnabled ?? this.greenScreenEnabled,
      outputFolder: outputFolder ?? this.outputFolder,
    );
  }
}

class SharingSettings {
  const SharingSettings({
    this.mailEnabled = false,
    this.smsEnabled = false,
    this.qrEnabled = true,
    this.saveToPcEnabled = true,
    this.senderEmail = '',
    this.senderPassword = '',
    this.mailBody = '',
    this.mailSubject = '',
    this.smtpHost = '',
    this.smtpPort = 587,
    this.receiverEmail = '',
    this.smsAuthToken = '',
    this.smsSid = '',
    this.smsFromNumber = '',
    this.smsTestNumber = '',
  }) : assert(smtpPort > 0);

  final bool mailEnabled;
  final bool smsEnabled;
  final bool qrEnabled;
  final bool saveToPcEnabled;
  final String senderEmail;
  final String senderPassword;
  final String mailBody;
  final String mailSubject;
  final String smtpHost;
  final int smtpPort;
  final String receiverEmail;
  final String smsAuthToken;
  final String smsSid;
  final String smsFromNumber;
  final String smsTestNumber;

  SharingSettings copyWith({
    bool? mailEnabled,
    bool? smsEnabled,
    bool? qrEnabled,
    bool? saveToPcEnabled,
    String? senderEmail,
    String? senderPassword,
    String? mailBody,
    String? mailSubject,
    String? smtpHost,
    int? smtpPort,
    String? receiverEmail,
    String? smsAuthToken,
    String? smsSid,
    String? smsFromNumber,
    String? smsTestNumber,
  }) {
    return SharingSettings(
      mailEnabled: mailEnabled ?? this.mailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      qrEnabled: qrEnabled ?? this.qrEnabled,
      saveToPcEnabled: saveToPcEnabled ?? this.saveToPcEnabled,
      senderEmail: senderEmail ?? this.senderEmail,
      senderPassword: senderPassword ?? this.senderPassword,
      mailBody: mailBody ?? this.mailBody,
      mailSubject: mailSubject ?? this.mailSubject,
      smtpHost: smtpHost ?? this.smtpHost,
      smtpPort: smtpPort ?? this.smtpPort,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      smsAuthToken: smsAuthToken ?? this.smsAuthToken,
      smsSid: smsSid ?? this.smsSid,
      smsFromNumber: smsFromNumber ?? this.smsFromNumber,
      smsTestNumber: smsTestNumber ?? this.smsTestNumber,
    );
  }
}

class PrintSettings {
  const PrintSettings({
    this.enabled = true,
    this.silentPrint = true,
    this.onePrintPerPhoto = false,
    this.useWindowsSettings = false,
    this.forceLandscape = false,
    this.forcePortrait = false,
    this.paperSize = PrintPaperSize.sixByFour,
    this.scaleMode = PrintScaleMode.fill,
    this.selectedPrinter = '',
    this.printLimit = 1,
    this.offsetTop = 0,
    this.offsetRight = 0,
    this.offsetBottom = 0,
    this.offsetLeft = 0,
  }) : assert(printLimit >= 0);

  final bool enabled;
  final bool silentPrint;
  final bool onePrintPerPhoto;
  final bool useWindowsSettings;
  final bool forceLandscape;
  final bool forcePortrait;
  final PrintPaperSize paperSize;
  final PrintScaleMode scaleMode;
  final String selectedPrinter;
  final int printLimit;
  final double offsetTop;
  final double offsetRight;
  final double offsetBottom;
  final double offsetLeft;

  PrintSettings copyWith({
    bool? enabled,
    bool? silentPrint,
    bool? onePrintPerPhoto,
    bool? useWindowsSettings,
    bool? forceLandscape,
    bool? forcePortrait,
    PrintPaperSize? paperSize,
    PrintScaleMode? scaleMode,
    String? selectedPrinter,
    int? printLimit,
    double? offsetTop,
    double? offsetRight,
    double? offsetBottom,
    double? offsetLeft,
  }) {
    return PrintSettings(
      enabled: enabled ?? this.enabled,
      silentPrint: silentPrint ?? this.silentPrint,
      onePrintPerPhoto: onePrintPerPhoto ?? this.onePrintPerPhoto,
      useWindowsSettings: useWindowsSettings ?? this.useWindowsSettings,
      forceLandscape: forceLandscape ?? this.forceLandscape,
      forcePortrait: forcePortrait ?? this.forcePortrait,
      paperSize: paperSize ?? this.paperSize,
      scaleMode: scaleMode ?? this.scaleMode,
      selectedPrinter: selectedPrinter ?? this.selectedPrinter,
      printLimit: printLimit ?? this.printLimit,
      offsetTop: offsetTop ?? this.offsetTop,
      offsetRight: offsetRight ?? this.offsetRight,
      offsetBottom: offsetBottom ?? this.offsetBottom,
      offsetLeft: offsetLeft ?? this.offsetLeft,
    );
  }
}

class SelfServiceSettings {
  const SelfServiceSettings({
    this.securityPin = '',
    this.runOnStartup = false,
    this.sharingLimit = 0,
    this.printLimitEachPhoto = 0,
  }) : assert(sharingLimit >= 0),
       assert(printLimitEachPhoto >= 0);

  final String securityPin;
  final bool runOnStartup;
  final int sharingLimit;
  final int printLimitEachPhoto;

  SelfServiceSettings copyWith({
    String? securityPin,
    bool? runOnStartup,
    int? sharingLimit,
    int? printLimitEachPhoto,
  }) {
    return SelfServiceSettings(
      securityPin: securityPin ?? this.securityPin,
      runOnStartup: runOnStartup ?? this.runOnStartup,
      sharingLimit: sharingLimit ?? this.sharingLimit,
      printLimitEachPhoto: printLimitEachPhoto ?? this.printLimitEachPhoto,
    );
  }
}

class ScreenTextSettings {
  const ScreenTextSettings({this.values = defaultValues});

  static const defaultValues = <String, String>{
    'photo': 'Photo',
    'photoDisabled': 'Photo capture is disabled in Main Settings.',
    'video': 'Video',
    'done': 'Done',
    'cancel': 'Cancel',
    'gallery': 'Gallery',
    'galleryDisabled': 'Gallery is disabled in Main Settings.',
    'print': 'Print',
    'close': 'Close',
    'email': 'E-mail',
    'qrPreparing': 'Preparing your download link',
    'qrShow': 'Scan the QR code to download',
    'startSession': 'Start Session',
    'sessionComplete': 'Session Complete',
    'buildCollage': 'Build Collage',
    'collageReady': 'Collage Ready',
    'collage': 'Collage',
    'downloadLink': 'Download Link',
    'emailCollage': 'Email Collage',
    'sendingEmail': 'Sending email...',
    'emailDisabled': 'Mail sharing is disabled in Sharing Settings.',
    'emailMissingReceiver': 'Set receiver email in Sharing Settings.',
    'smsLink': 'SMS Link',
    'sendingSms': 'Sending SMS...',
    'smsDisabled': 'SMS sharing is disabled in Sharing Settings.',
    'smsMissingReceiver': 'Set SMS test phone number in Sharing Settings.',
    'sharingLimitReached': 'Sharing limit reached for this event.',
    'printing': 'Printing...',
    'printCollage': 'Print Collage',
    'printingDisabled': 'Printing is disabled in Print Settings.',
    'selectPrinter': 'Select a printer in Print Settings.',
    'photoItem': 'Photo',
  };

  final Map<String, String> values;

  String text(String key) => values[key] ?? defaultValues[key] ?? key;

  ScreenTextSettings copyWithValue(String key, String value) {
    return ScreenTextSettings(values: {...values, key: value});
  }

  ScreenTextSettings copyWithValues(Map<String, String> nextValues) {
    return ScreenTextSettings(values: {...values, ...nextValues});
  }
}

class ScreenThemeSettings {
  const ScreenThemeSettings({
    this.themeColor = 0xff2563eb,
    this.homeBackgroundColor = 0xff101820,
    this.backgroundImagePath = '',
    this.homeBackgroundImageEnabled = false,
  });

  final int themeColor;
  final int homeBackgroundColor;
  final String backgroundImagePath;
  final bool homeBackgroundImageEnabled;

  ScreenThemeSettings copyWith({
    int? themeColor,
    int? homeBackgroundColor,
    String? backgroundImagePath,
    bool? homeBackgroundImageEnabled,
  }) {
    return ScreenThemeSettings(
      themeColor: themeColor ?? this.themeColor,
      homeBackgroundColor: homeBackgroundColor ?? this.homeBackgroundColor,
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      homeBackgroundImageEnabled:
          homeBackgroundImageEnabled ?? this.homeBackgroundImageEnabled,
    );
  }
}
