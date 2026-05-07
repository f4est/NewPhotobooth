class PrintJob {
  const PrintJob({
    required this.filePath,
    required this.printerName,
    this.copies = 1,
    this.paperName = '6 x 4 in',
    this.paperWidthInches = 6,
    this.paperHeightInches = 4,
    this.scaleMode = PrintJobScaleMode.fill,
    this.useWindowsSettings = false,
    this.forceLandscape = false,
    this.forcePortrait = false,
    this.offsetTop = 0,
    this.offsetRight = 0,
    this.offsetBottom = 0,
    this.offsetLeft = 0,
  }) : assert(copies > 0),
       assert(!(forceLandscape && forcePortrait));

  final String filePath;
  final String printerName;
  final int copies;
  final String paperName;
  final double paperWidthInches;
  final double paperHeightInches;
  final PrintJobScaleMode scaleMode;
  final bool useWindowsSettings;
  final bool forceLandscape;
  final bool forcePortrait;
  final double offsetTop;
  final double offsetRight;
  final double offsetBottom;
  final double offsetLeft;
}

enum PrintJobScaleMode { fit, fill }
