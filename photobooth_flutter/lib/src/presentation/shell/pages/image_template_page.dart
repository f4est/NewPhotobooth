import 'dart:io';

import 'package:flutter/material.dart';

import '../../../domain/templates/image_template.dart';
import '../../templates/template_controller.dart';
import '../shell_chrome.dart';

class ImageTemplatePage extends StatelessWidget {
  const ImageTemplatePage({required this.controller, super.key});

  final TemplateController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TemplateState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final template = state.catalog.selectedTemplate;

        return AdminPage(
          title: 'Image Template Settings',
          subtitle:
              'Configure output size, photo slots and optional PNG overlay.',
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            AdminPanel(
              title: 'Template Properties',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _NumberField(
                          label: 'Output Width',
                          value: template.outputWidth,
                          onChanged: (value) => controller.updateSelected(
                            template.copyWith(outputWidth: value),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _NumberField(
                          label: 'Output Height',
                          value: template.outputHeight,
                          onChanged: (value) => controller.updateSelected(
                            template.copyWith(outputHeight: value),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const FormFieldLabel('Overlay PNG Path'),
                  CompactInput(
                    initialValue: template.overlayImagePath,
                    hint: 'C:\\Frames\\frame.png',
                    onChanged: controller.setOverlayPath,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    template.overlayImagePath.trim().isEmpty
                        ? 'No overlay selected.'
                        : File(template.overlayImagePath).existsSync()
                        ? 'Overlay file found.'
                        : 'Overlay file not found.',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          template.overlayImagePath.trim().isEmpty ||
                              File(template.overlayImagePath).existsSync()
                          ? Colors.black54
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            AdminPanel(
              title: 'Photo Slots',
              child: Column(
                children: [
                  for (
                    var index = 0;
                    index < template.photoSlots.length;
                    index += 1
                  )
                    _SlotEditor(
                      index: index,
                      slot: template.photoSlots[index],
                      onChanged: (slot) => controller.updateSlot(index, slot),
                      onRemove: () => controller.removeSlot(index),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed: controller.addSlot,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Photo Slot'),
                    ),
                  ),
                ],
              ),
            ),
            AdminPanel(
              title: 'Template Preview',
              child: _TemplatePreview(
                template: template,
                onSlotChanged: controller.updateSlot,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SlotEditor extends StatelessWidget {
  const _SlotEditor({
    required this.index,
    required this.slot,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final TemplatePhotoSlot slot;
  final ValueChanged<TemplatePhotoSlot> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(width: 84, child: Text('Slot ${index + 1}')),
          Expanded(
            child: _NumberField(
              label: 'X',
              value: slot.x,
              min: 0,
              onChanged: (value) => onChanged(slot.copyWith(x: value)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _NumberField(
              label: 'Y',
              value: slot.y,
              min: 0,
              onChanged: (value) => onChanged(slot.copyWith(y: value)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _NumberField(
              label: 'W',
              value: slot.width,
              onChanged: (value) => onChanged(slot.copyWith(width: value)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _NumberField(
              label: 'H',
              value: slot.height,
              onChanged: (value) => onChanged(slot.copyWith(height: value)),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label),
        CompactInput(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          onChanged: (raw) {
            final parsed = int.tryParse(raw);
            if (parsed != null && parsed >= min) {
              onChanged(parsed);
            }
          },
        ),
      ],
    );
  }
}

class _TemplatePreview extends StatelessWidget {
  const _TemplatePreview({required this.template, required this.onSlotChanged});

  final ImageTemplate template;
  final void Function(int index, TemplatePhotoSlot slot) onSlotChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Drag slots to reposition. Drag the bottom-right handle to resize.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420, maxHeight: 520),
            child: AspectRatio(
              aspectRatio: template.outputWidth / template.outputHeight,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xffe5e7eb),
                  border: Border.all(color: const Color(0xffcbd5e1)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scaleX = constraints.maxWidth / template.outputWidth;
                    final scaleY =
                        constraints.maxHeight / template.outputHeight;

                    return Stack(
                      children: [
                        for (
                          var index = 0;
                          index < template.photoSlots.length;
                          index += 1
                        )
                          _InteractiveSlot(
                            index: index,
                            slot: template.photoSlots[index],
                            scaleX: scaleX,
                            scaleY: scaleY,
                            template: template,
                            onChanged: onSlotChanged,
                          ),
                        if (template.overlayImagePath.trim().isNotEmpty &&
                            File(template.overlayImagePath).existsSync())
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Image.file(
                                File(template.overlayImagePath),
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InteractiveSlot extends StatelessWidget {
  const _InteractiveSlot({
    required this.index,
    required this.slot,
    required this.scaleX,
    required this.scaleY,
    required this.template,
    required this.onChanged,
  });

  final int index;
  final TemplatePhotoSlot slot;
  final double scaleX;
  final double scaleY;
  final ImageTemplate template;
  final void Function(int index, TemplatePhotoSlot slot) onChanged;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: slot.x * scaleX,
      top: slot.y * scaleY,
      width: slot.width * scaleX,
      height: slot.height * scaleY,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (details) {
          onChanged(
            index,
            _clamp(
              slot.copyWith(
                x: slot.x + (details.delta.dx / scaleX).round(),
                y: slot.y + (details.delta.dy / scaleY).round(),
              ),
            ),
          );
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            border: Border.all(color: const Color(0xff2563eb), width: 2),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Text(
                  'Photo ${index + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    onChanged(
                      index,
                      _clamp(
                        slot.copyWith(
                          width:
                              slot.width + (details.delta.dx / scaleX).round(),
                          height:
                              slot.height + (details.delta.dy / scaleY).round(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    color: const Color(0xff2563eb),
                    child: const Icon(
                      Icons.open_in_full,
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TemplatePhotoSlot _clamp(TemplatePhotoSlot next) {
    final width = next.width.clamp(1, template.outputWidth);
    final height = next.height.clamp(1, template.outputHeight);
    final x = next.x.clamp(0, template.outputWidth - width);
    final y = next.y.clamp(0, template.outputHeight - height);
    return TemplatePhotoSlot(x: x, y: y, width: width, height: height);
  }
}
