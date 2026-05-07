import 'package:flutter/material.dart';

import 'photobooth_admin_shell.dart';

const _accent = Color(0xff2563eb);
const _sidebar = Color(0xff172033);
const _pageBackground = Color(0xfff5f7fb);

class ShellChrome extends StatelessWidget {
  const ShellChrome({
    required this.selected,
    required this.showPhotoApp,
    required this.onSectionSelected,
    required this.onStartApp,
    required this.onCloseApp,
    required this.onSupport,
    required this.onSystem,
    required this.child,
    super.key,
  });

  final AdminSection selected;
  final bool showPhotoApp;
  final ValueChanged<AdminSection> onSectionSelected;
  final VoidCallback onStartApp;
  final VoidCallback onCloseApp;
  final VoidCallback onSupport;
  final VoidCallback onSystem;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Row(
        children: [
          SizedBox(
            width: 248,
            child: _Sidebar(
              selected: selected,
              showPhotoApp: showPhotoApp,
              onSectionSelected: onSectionSelected,
              onStartApp: onStartApp,
              onCloseApp: onCloseApp,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(onSupport: onSupport, onSystem: onSystem),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(36, 22, 36, 48),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 720,
                            maxWidth: 980,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.selected,
    required this.showPhotoApp,
    required this.onSectionSelected,
    required this.onStartApp,
    required this.onCloseApp,
  });

  final AdminSection selected;
  final bool showPhotoApp;
  final ValueChanged<AdminSection> onSectionSelected;
  final VoidCallback onStartApp;
  final VoidCallback onCloseApp;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _sidebar,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Booth Control',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Photo, print and sharing workflow',
                style: TextStyle(color: Color(0xff94a3b8), fontSize: 11),
              ),
              const SizedBox(height: 18),
              for (final section in AdminSection.values)
                _NavItem(
                  section: section,
                  selected: !showPhotoApp && selected == section,
                  onTap: () => onSectionSelected(section),
                ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _SidebarPillButton(
                      label: 'Open Booth',
                      onPressed: onStartApp,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SidebarPillButton(label: 'Close', onPressed: onCloseApp),
                ],
              ),
              const SizedBox(height: 14),
              const _SystemStatus(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final AdminSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                section.icon,
                size: 18,
                color: selected ? Colors.white : const Color(0xffcbd5e1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xffcbd5e1),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarPillButton extends StatelessWidget {
  const _SidebarPillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _sidebar,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
        ),
        child: Text(label, maxLines: 1),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSupport, required this.onSystem});

  final VoidCallback onSupport;
  final VoidCallback onSystem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Row(
          children: [
            const Text(
              'Admin Console',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: onSupport,
              icon: const Icon(Icons.help_outline, size: 18),
              label: const Text('Support'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: onSystem,
              icon: const Icon(Icons.settings_outlined, size: 18),
              label: const Text('System'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemStatus extends StatelessWidget {
  const _SystemStatus();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local workspace',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'Settings, events, media and templates are stored on this PC.',
            style: TextStyle(
              color: Color(0xffcbd5e1),
              fontSize: 11,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({
    required this.title,
    required this.subtitle,
    required this.children,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xff111827),
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xff64748b)),
        ),
        const SizedBox(height: 22),
        ...children,
      ],
    );
  }
}

class AdminPanel extends StatelessWidget {
  const AdminPanel({required this.title, required this.child, super.key});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 12),
            child: Text(
              title,
              style: const TextStyle(
                color: _accent,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(22), child: child),
        ],
      ),
    );
  }
}

class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class CompactInput extends StatelessWidget {
  const CompactInput({
    this.hint = '',
    this.initialValue,
    this.onChanged,
    this.keyboardType,
    super.key,
  });

  final String hint;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: TextFormField(
        key: ValueKey(initialValue),
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 9,
          ),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

class OptionSwitch extends StatelessWidget {
  const OptionSwitch({
    required this.label,
    this.value = false,
    this.onChanged,
    super.key,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(value: value, onChanged: onChanged),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
