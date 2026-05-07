class CapturedPhoto {
  const CapturedPhoto({
    required this.id,
    required this.filePath,
    required this.capturedAt,
  });

  final String id;
  final String filePath;
  final DateTime capturedAt;
}
