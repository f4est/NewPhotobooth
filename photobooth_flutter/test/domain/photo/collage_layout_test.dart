import 'package:flutter_test/flutter_test.dart';
import 'package:photobooth_flutter/src/domain/photo/collage_layout.dart';

void main() {
  test('grid creates one slot for each expected photo', () {
    final layout = CollageLayout.grid(photoCount: 4);

    expect(layout.slots, hasLength(4));
    expect(layout.canvasWidth, 1200);
    expect(layout.canvasHeight, 1800);
  });

  test('grid keeps every slot inside the canvas', () {
    final layout = CollageLayout.grid(photoCount: 3);

    for (final slot in layout.slots) {
      expect(slot.left, greaterThanOrEqualTo(0));
      expect(slot.top, greaterThanOrEqualTo(0));
      expect(slot.left + slot.width, lessThanOrEqualTo(layout.canvasWidth));
      expect(slot.top + slot.height, lessThanOrEqualTo(layout.canvasHeight));
    }
  });

  test('grid rejects empty collages', () {
    expect(() => CollageLayout.grid(photoCount: 0), throwsArgumentError);
  });

  test('vertical strip creates stacked slots', () {
    final layout = CollageLayout.stripVertical(photoCount: 3);

    expect(layout.slots, hasLength(3));
    expect(layout.slots[1].top, greaterThan(layout.slots[0].top));
    expect(layout.slots[1].left, layout.slots[0].left);
  });

  test('horizontal strip creates side by side slots', () {
    final layout = CollageLayout.stripHorizontal(photoCount: 3);

    expect(layout.slots, hasLength(3));
    expect(layout.slots[1].left, greaterThan(layout.slots[0].left));
    expect(layout.slots[1].top, layout.slots[0].top);
  });
}
