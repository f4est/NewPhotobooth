class PhotoCaptureSettings {
  const PhotoCaptureSettings({
    this.photoCount = 4,
    this.countdownSeconds = 3,
    this.mirrorPreview = true,
    this.rotateDegrees = 0,
  }) : assert(photoCount > 0),
       assert(countdownSeconds >= 0),
       assert(
         rotateDegrees == 0 ||
             rotateDegrees == 90 ||
             rotateDegrees == 180 ||
             rotateDegrees == 270,
       );

  final int photoCount;
  final int countdownSeconds;
  final bool mirrorPreview;
  final int rotateDegrees;
}
