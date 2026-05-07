class CollageSlot {
  const CollageSlot({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  final double left;
  final double top;
  final double width;
  final double height;
}

class CollageLayout {
  const CollageLayout({
    required this.canvasWidth,
    required this.canvasHeight,
    required this.slots,
  }) : assert(canvasWidth > 0),
       assert(canvasHeight > 0),
       assert(slots.length > 0);

  final double canvasWidth;
  final double canvasHeight;
  final List<CollageSlot> slots;

  factory CollageLayout.grid({
    required int photoCount,
    double canvasWidth = 1200,
    double canvasHeight = 1800,
    double gap = 24,
    double margin = 48,
  }) {
    if (photoCount <= 0) {
      throw ArgumentError.value(photoCount, 'photoCount');
    }

    final columns = photoCount == 1 ? 1 : 2;
    final rows = (photoCount / columns).ceil();
    final slotWidth =
        (canvasWidth - (margin * 2) - (gap * (columns - 1))) / columns;
    final slotHeight =
        (canvasHeight - (margin * 2) - (gap * (rows - 1))) / rows;

    return CollageLayout(
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      slots: List.generate(photoCount, (index) {
        final column = index % columns;
        final row = index ~/ columns;

        return CollageSlot(
          left: margin + column * (slotWidth + gap),
          top: margin + row * (slotHeight + gap),
          width: slotWidth,
          height: slotHeight,
        );
      }),
    );
  }

  factory CollageLayout.stripVertical({
    required int photoCount,
    double canvasWidth = 1200,
    double canvasHeight = 1800,
    double gap = 18,
    double margin = 48,
  }) {
    if (photoCount <= 0) {
      throw ArgumentError.value(photoCount, 'photoCount');
    }

    final slotHeight =
        (canvasHeight - (margin * 2) - (gap * (photoCount - 1))) / photoCount;
    final slotWidth = canvasWidth - margin * 2;

    return CollageLayout(
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      slots: List.generate(photoCount, (index) {
        return CollageSlot(
          left: margin,
          top: margin + index * (slotHeight + gap),
          width: slotWidth,
          height: slotHeight,
        );
      }),
    );
  }

  factory CollageLayout.stripHorizontal({
    required int photoCount,
    double canvasWidth = 1800,
    double canvasHeight = 1200,
    double gap = 18,
    double margin = 48,
  }) {
    if (photoCount <= 0) {
      throw ArgumentError.value(photoCount, 'photoCount');
    }

    final slotWidth =
        (canvasWidth - (margin * 2) - (gap * (photoCount - 1))) / photoCount;
    final slotHeight = canvasHeight - margin * 2;

    return CollageLayout(
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
      slots: List.generate(photoCount, (index) {
        return CollageSlot(
          left: margin + index * (slotWidth + gap),
          top: margin,
          width: slotWidth,
          height: slotHeight,
        );
      }),
    );
  }
}
