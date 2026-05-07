import 'package:flutter/material.dart';

import '../../../domain/events/booth_event.dart';
import '../../events/event_controller.dart';
import '../shell_chrome.dart';

class EventManagementPage extends StatelessWidget {
  const EventManagementPage({required this.controller, super.key});

  final EventController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<EventState>(
      valueListenable: controller,
      builder: (context, state, _) {
        final catalog = state.catalog;

        return AdminPage(
          title: 'Event Management',
          subtitle:
              'Create, reuse and archive booth events. Media counters are tied to the current event.',
          children: [
            if (state.isLoading) const LinearProgressIndicator(),
            AdminPanel(
              title: 'Current Event',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CurrentEventCard(event: catalog.currentEvent),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: controller.closeAndStartNewEvent,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Close and Start New Event'),
                      ),
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: () => _showRenameDialog(
                          context,
                          catalog.currentEvent.name,
                          controller.renameCurrentEvent,
                        ),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit Event'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: controller.copyCurrentEvent,
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('Copy Event'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AdminPanel(
              title: 'Event Archive',
              child: catalog.archive.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Text('No archived events yet.'),
                    )
                  : Column(
                      children: [
                        for (final event in catalog.archive)
                          _ArchiveRow(
                            event: event,
                            onReuse: () =>
                                controller.reuseArchivedEvent(event.id),
                          ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    String currentName,
    ValueChanged<String> onSubmit,
  ) async {
    final textController = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Event'),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Event name'),
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(textController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      onSubmit(result);
    }
  }
}

class _CurrentEventCard extends StatelessWidget {
  const _CurrentEventCard({required this.event});

  final BoothEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffbfdbfe)),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xffeff6ff),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(event.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          _Counter(label: 'Media Collected', value: event.mediaCollected),
          const SizedBox(width: 18),
          _Counter(label: 'Media Shared', value: event.mediaShared),
          const SizedBox(width: 18),
          _Counter(label: 'Media Printed', value: event.mediaPrinted),
        ],
      ),
    );
  }
}

class _ArchiveRow extends StatelessWidget {
  const _ArchiveRow({required this.event, required this.onReuse});

  final BoothEvent event;
  final VoidCallback onReuse;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xffe5e7eb),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              event.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            _formatDate(event.createdAt),
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(width: 16),
          Text('${event.mediaCollected} media'),
          const SizedBox(width: 16),
          FilledButton.tonal(onPressed: onReuse, child: const Text('Re-Use')),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('$value', style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}
