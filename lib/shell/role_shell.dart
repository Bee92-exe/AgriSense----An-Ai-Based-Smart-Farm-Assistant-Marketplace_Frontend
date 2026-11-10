import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/mic_fab.dart';
import '../features/voice/voice_sheet.dart';

/// One navigation destination in a role shell.
class ShellDestination {
  const ShellDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.builder,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final WidgetBuilder builder;
}

/// The chrome every signed-in role shares.
///
/// Four near-identical shell widgets were the alternative; one parameterised
/// shell means the tap-target floor, the nav label behaviour and the mic
/// placement are defined once. The farmer is the only role that gets
/// [showMic] — the PRD restricts voice control to farmers, and a mic on a vendor
/// screen would imply a capability that does not exist.
class RoleShell extends ConsumerStatefulWidget {
  const RoleShell({
    super.key,
    required this.destinations,
    this.initialIndex = 0,
    this.showMic = false,
    this.banner,
  });

  final List<ShellDestination> destinations;
  final int initialIndex;
  final bool showMic;

  /// Rendered above the body — used for the offline banner.
  final Widget? banner;

  @override
  ConsumerState<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends ConsumerState<RoleShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.background,
      body: Column(
        children: [
          ?widget.banner,
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                for (final d in widget.destinations) d.builder(context),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: p.outline, width: p.borderWidth),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final d in widget.destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.activeIcon),
                label: d.label,
              ),
          ],
        ),
      ),
      floatingActionButton: widget.showMic
          ? Padding(
              // Clear of the navigation bar so the mic never overlaps a nav
              // label.
              padding: const EdgeInsets.only(bottom: 8),
              child: MicFab(
                onPressed: () => showVoiceSheet(context),
                isEnabled: true,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

}
