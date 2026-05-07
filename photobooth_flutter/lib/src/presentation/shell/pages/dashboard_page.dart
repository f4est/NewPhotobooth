import 'package:flutter/material.dart';

import '../../../domain/gallery/media_gallery_item.dart';
import '../../../domain/settings/app_settings.dart';
import '../../events/event_controller.dart';
import '../../gallery/media_gallery_controller.dart';
import '../../printing/printer_controller.dart';
import '../../settings/settings_controller.dart';
import '../photobooth_admin_shell.dart';
import '../shell_chrome.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.settingsController,
    required this.eventController,
    required this.printerController,
    required this.mediaGalleryController,
    required this.onOpenBooth,
    required this.onNavigate,
    super.key,
  });

  final SettingsController settingsController;
  final EventController eventController;
  final PrinterController printerController;
  final MediaGalleryController mediaGalleryController;
  final VoidCallback onOpenBooth;
  final ValueChanged<AdminSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SettingsState>(
      valueListenable: settingsController,
      builder: (context, settingsState, _) {
        return ValueListenableBuilder<EventState>(
          valueListenable: eventController,
          builder: (context, eventState, _) {
            return ValueListenableBuilder<PrinterState>(
              valueListenable: printerController,
              builder: (context, printerState, _) {
                return ValueListenableBuilder<MediaGalleryState>(
                  valueListenable: mediaGalleryController,
                  builder: (context, galleryState, _) {
                    final settings = settingsState.settings;
                    final event = eventState.catalog.currentEvent;
                    final warnings = _warnings(settings, printerState);
                    final photos = galleryState.items
                        .where(
                          (item) => item.type == MediaGalleryItemType.photo,
                        )
                        .length;
                    final collages = galleryState.items
                        .where(
                          (item) => item.type == MediaGalleryItemType.collage,
                        )
                        .length;

                    return AdminPage(
                      title: 'Dashboard',
                      subtitle:
                          'Operational overview for the active booth event.',
                      children: [
                        _StatusHeader(
                          eventName: event.name,
                          outputFolder: _outputFolderLabel(settings),
                          warnings: warnings,
                          onOpenBooth: onOpenBooth,
                          onRefresh: () {
                            printerController.refresh();
                            mediaGalleryController.refresh();
                          },
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _MetricGrid(
                                collected: event.mediaCollected,
                                printed: event.mediaPrinted,
                                shared: event.mediaShared,
                                photos: photos,
                                collages: collages,
                              ),
                            ),
                            const SizedBox(width: 18),
                            SizedBox(
                              width: 310,
                              child: _ReadinessPanel(
                                settings: settings,
                                printerState: printerState,
                                warnings: warnings,
                                onNavigate: onNavigate,
                              ),
                            ),
                          ],
                        ),
                        _QuickActionsPanel(
                          onOpenBooth: onOpenBooth,
                          onNavigate: onNavigate,
                        ),
                        _RecentMediaPanel(
                          controller: mediaGalleryController,
                          items: galleryState.items.take(6).toList(),
                          isLoading: galleryState.isLoading,
                          onOpenGallery: () => onNavigate(AdminSection.gallery),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<_DashboardWarning> _warnings(
    AppSettings settings,
    PrinterState printerState,
  ) {
    final warnings = <_DashboardWarning>[];

    if (settings.camera.cameraName.trim().isEmpty) {
      warnings.add(
        const _DashboardWarning(
          title: 'Camera is not selected',
          action: AdminSection.mainSettings,
        ),
      );
    }

    if (settings.print.enabled) {
      if (settings.print.selectedPrinter.trim().isEmpty) {
        warnings.add(
          const _DashboardWarning(
            title: 'Printer is not selected',
            action: AdminSection.print,
          ),
        );
      } else if (!printerState.isLoading &&
          printerState.printers.isNotEmpty &&
          !printerState.printers.contains(settings.print.selectedPrinter)) {
        warnings.add(
          const _DashboardWarning(
            title: 'Selected printer is not available',
            action: AdminSection.print,
          ),
        );
      }
    }

    if (!settings.sharing.qrEnabled &&
        !settings.sharing.saveToPcEnabled &&
        !settings.sharing.mailEnabled &&
        !settings.sharing.smsEnabled) {
      warnings.add(
        const _DashboardWarning(
          title: 'No sharing method is enabled',
          action: AdminSection.sharing,
        ),
      );
    }

    return warnings;
  }

  String _outputFolderLabel(AppSettings settings) {
    final folder = settings.shooting.outputFolder.trim();
    return folder.isEmpty ? 'Pictures\\NewPhotobooth' : folder;
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({
    required this.eventName,
    required this.outputFolder,
    required this.warnings,
    required this.onOpenBooth,
    required this.onRefresh,
  });

  final String eventName;
  final String outputFolder;
  final List<_DashboardWarning> warnings;
  final VoidCallback onOpenBooth;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final isReady = warnings.isEmpty;

    return AdminPanel(
      title: 'Current Event',
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle_outline : Icons.error_outline,
            color: isReady ? const Color(0xff15803d) : const Color(0xffb45309),
            size: 38,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isReady
                      ? 'Ready to run. Media will be saved to $outputFolder.'
                      : '${warnings.length} setup item(s) need attention before running.',
                  style: const TextStyle(color: Color(0xff64748b)),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: onOpenBooth,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Open Booth'),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({
    required this.collected,
    required this.printed,
    required this.shared,
    required this.photos,
    required this.collages,
  });

  final int collected;
  final int printed;
  final int shared;
  final int photos;
  final int collages;

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      title: 'Event Counters',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.15,
        children: [
          _MetricTile(
            label: 'Collected',
            value: collected,
            icon: Icons.camera_alt_outlined,
          ),
          _MetricTile(label: 'Printed', value: printed, icon: Icons.print),
          _MetricTile(label: 'Shared', value: shared, icon: Icons.share),
          _MetricTile(
            label: 'Files',
            value: photos + collages,
            icon: Icons.folder_copy_outlined,
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        border: Border.all(color: const Color(0xffe2e8f0)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xff2563eb)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadinessPanel extends StatelessWidget {
  const _ReadinessPanel({
    required this.settings,
    required this.printerState,
    required this.warnings,
    required this.onNavigate,
  });

  final AppSettings settings;
  final PrinterState printerState;
  final List<_DashboardWarning> warnings;
  final ValueChanged<AdminSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      title: 'Setup Status',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatusRow(
            label: 'Camera',
            value: settings.camera.cameraName.trim().isEmpty
                ? 'Not selected'
                : settings.camera.cameraName,
            ok: settings.camera.cameraName.trim().isNotEmpty,
          ),
          _StatusRow(
            label: 'Printer',
            value: settings.print.enabled
                ? settings.print.selectedPrinter.trim().isEmpty
                      ? 'Not selected'
                      : settings.print.selectedPrinter
                : 'Disabled',
            ok:
                !settings.print.enabled ||
                settings.print.selectedPrinter.trim().isNotEmpty,
          ),
          _StatusRow(
            label: 'Photo Size',
            value: settings.print.paperSize.label,
            ok: true,
          ),
          _StatusRow(
            label: 'Sharing',
            value: _sharingLabel(settings),
            ok:
                settings.sharing.qrEnabled ||
                settings.sharing.saveToPcEnabled ||
                settings.sharing.mailEnabled ||
                settings.sharing.smsEnabled,
          ),
          if (warnings.isNotEmpty) ...[
            const Divider(height: 26),
            for (final warning in warnings)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton.icon(
                  onPressed: () => onNavigate(warning.action),
                  icon: const Icon(Icons.build_outlined, size: 18),
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(warning.title),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  String _sharingLabel(AppSettings settings) {
    final enabled = <String>[
      if (settings.sharing.qrEnabled) 'QR',
      if (settings.sharing.saveToPcEnabled) 'Save',
      if (settings.sharing.mailEnabled) 'Mail',
      if (settings.sharing.smsEnabled) 'SMS',
    ];
    return enabled.isEmpty ? 'Disabled' : enabled.join(', ');
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.ok,
  });

  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.warning_amber_rounded,
            size: 18,
            color: ok ? const Color(0xff15803d) : const Color(0xffb45309),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel({
    required this.onOpenBooth,
    required this.onNavigate,
  });

  final VoidCallback onOpenBooth;
  final ValueChanged<AdminSection> onNavigate;

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      title: 'Quick Actions',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          FilledButton.icon(
            onPressed: onOpenBooth,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Open Booth'),
          ),
          OutlinedButton.icon(
            onPressed: () => onNavigate(AdminSection.events),
            icon: const Icon(Icons.event_note_outlined),
            label: const Text('Manage Events'),
          ),
          OutlinedButton.icon(
            onPressed: () => onNavigate(AdminSection.mainSettings),
            icon: const Icon(Icons.photo_camera_outlined),
            label: const Text('Camera Settings'),
          ),
          OutlinedButton.icon(
            onPressed: () => onNavigate(AdminSection.imageTemplate),
            icon: const Icon(Icons.layers_outlined),
            label: const Text('Template Editor'),
          ),
          OutlinedButton.icon(
            onPressed: () => onNavigate(AdminSection.print),
            icon: const Icon(Icons.print_outlined),
            label: const Text('Print Settings'),
          ),
          OutlinedButton.icon(
            onPressed: () => onNavigate(AdminSection.sharing),
            icon: const Icon(Icons.share_outlined),
            label: const Text('Sharing Settings'),
          ),
        ],
      ),
    );
  }
}

class _RecentMediaPanel extends StatelessWidget {
  const _RecentMediaPanel({
    required this.controller,
    required this.items,
    required this.isLoading,
    required this.onOpenGallery,
  });

  final MediaGalleryController controller;
  final List<MediaGalleryItem> items;
  final bool isLoading;
  final VoidCallback onOpenGallery;

  @override
  Widget build(BuildContext context) {
    return AdminPanel(
      title: 'Recent Media',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(isLoading ? 'Loading media...' : '${items.length} shown'),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
              const SizedBox(width: 10),
              FilledButton.tonalIcon(
                onPressed: onOpenGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Open Gallery'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Text('No media created for this event yet.')
          else
            for (final item in items)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(_mediaIcon(item.type)),
                title: Text(
                  item.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(_formatDateTime(item.modifiedAt)),
                trailing: IconButton(
                  tooltip: 'Open file',
                  icon: const Icon(Icons.open_in_new),
                  onPressed: () => controller.openFile(item.filePath),
                ),
              ),
        ],
      ),
    );
  }

  IconData _mediaIcon(MediaGalleryItemType type) {
    return switch (type) {
      MediaGalleryItemType.photo => Icons.image_outlined,
      MediaGalleryItemType.collage => Icons.dashboard_customize_outlined,
      MediaGalleryItemType.other => Icons.movie_outlined,
    };
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.${date.year} $hour:$minute';
  }
}

class _DashboardWarning {
  const _DashboardWarning({required this.title, required this.action});

  final String title;
  final AdminSection action;
}
