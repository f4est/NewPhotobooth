import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/infrastructure/media/safe_path.dart';

void main() {
  test('safePathSegment replaces invalid Windows path characters', () {
    expect(safePathSegment('Wedding: A/B?C*'), 'Wedding_ A_B_C_');
  });

  test('safePathSegment returns Untitled for empty values', () {
    expect(safePathSegment('   '), 'Untitled');
  });
}
