String safePathSegment(String value) {
  final sanitized = value
      .trim()
      .replaceAll(RegExp(r'[<>:"/\\|?*\x00-\x1F]'), '_')
      .replaceAll(RegExp(r'\s+'), ' ');

  if (sanitized.isEmpty) {
    return 'Untitled';
  }

  return sanitized.length > 80 ? sanitized.substring(0, 80) : sanitized;
}
