import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/session_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/states.dart';
import '../data/models/enums.dart';
import '../features/admin/admin_home_screen.dart';
import '../features/admin/admin_screens.dart';
import '../features/expert/expert_home_screen.dart';
import '../features/staff/staff_profile_screen.dart';
import '../features/vendor/vendor_home_screen.dart';
import '../features/vendor/vendor_screens.dart';
import '../l10n/app_localizations.dart';

/// The shell for the three non-farmer roles.
///
/// Vendor, expert and admin are the same binary with different tabs (decision
/// D2), so this is one screen that reads the role rather than three near-copies.
/// None of them get a microphone — voice control is farmer-only by requirement,
/// and a mic here would advertise a capability the backend refuses.
///
/// The selected tab lives in a provider per role so a dashboard quick action can
/// send the user to the queue that needs them.
class VendorShell extends ConsumerWidget {
  const VendorShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(body: LoadingState(rows: 3));
    }

    final tabs = _tabsFor(user.role, l, ref);
    final controller = switch (user.role) {
      Role.vendor => ref.watch(vendorTabProvider),
      Role.expert => ref.watch(expertTabProvider),
      Role.admin => ref.watch(adminTabProvider),
      Role.farmer => ref.watch(vendorTabProvider),
    };

    return ValueListenableBuilder<int>(
      valueListenable: controller,
      builder: (context, index, _) {
        // A role switch (or a shortened list) must never point past the end.
        final safeIndex = index.clamp(0, tabs.length - 1);

        return Scaffold(
          backgroundColor: p.background,
          body: SafeArea(
            bottom: false,
            child: IndexedStack(
              index: safeIndex,
              children: [for (final tab in tabs) tab.child],
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              color: p.surface,
              border: Border(
                top: BorderSide(color: p.outline, width: p.borderWidth),
              ),
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: p.surface,
                indicatorColor: p.primaryContainer,
                elevation: 0,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                labelTextStyle: WidgetStateProperty.resolveWith(
                  (states) => context.texts.labelSmall?.copyWith(
                    fontWeight: states.contains(WidgetState.selected)
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: states.contains(WidgetState.selected)
                        ? p.primary
                        : p.onSurfaceMuted,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: safeIndex,
                onDestinationSelected: (i) => controller.value = i,
                destinations: [
                  for (final tab in tabs)
                    NavigationDestination(
                      icon: _withBadge(
                        Icon(tab.icon),
                        tab.badge,
                        p.harvest,
                      ),
                      selectedIcon: _withBadge(
                        Icon(tab.activeIcon),
                        tab.badge,
                        p.harvest,
                      ),
                      label: tab.label,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _withBadge(Widget icon, int? count, Color color) {
    if (count == null || count <= 0) return icon;
    return Badge(
      backgroundColor: color,
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
      ),
      child: icon,
    );
  }
}

/// One tab: its icon pair, its Bangla label, the screen behind it and an
/// optional queue count that is a real number, never a decorative dot.
typedef _Tab = ({
  IconData icon,
  IconData activeIcon,
  String label,
  Widget child,
  int? badge,
});

List<_Tab> _tabsFor(Role role, AppL10n l, WidgetRef ref) => switch (role) {
      Role.vendor => [
          (
            icon: Icons.space_dashboard_outlined,
            activeIcon: Icons.space_dashboard_rounded,
            label: l.navDashboard,
            child: const VendorHomeScreen(),
            badge: null,
          ),
          (
            icon: Icons.inventory_2_outlined,
            activeIcon: Icons.inventory_2_rounded,
            label: l.navProducts,
            child: const VendorProductsScreen(),
            badge: null,
          ),
          (
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long_rounded,
            label: l.navOrders,
            child: const VendorOrdersScreen(),
            badge: ref.watch(vendorDeskProvider).value?.pendingOrders,
          ),
          (
            icon: Icons.insights_outlined,
            activeIcon: Icons.insights_rounded,
            label: l.vendorBusiness,
            child: const VendorBusinessScreen(),
            badge: null,
          ),
          (
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l.navProfile,
            child: const StaffProfileScreen(),
            badge: null,
          ),
        ],
      Role.expert => [
          (
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: l.expertHome,
            child: const ExpertHomeScreen(),
            badge: null,
          ),
          (
            icon: Icons.forum_outlined,
            activeIcon: Icons.forum_rounded,
            label: l.expertQuestions,
            child: const ExpertQuestionsScreen(),
            badge:
                ref.watch(expertDeskProvider).value?.openQuestions.length,
          ),
          (
            icon: Icons.auto_stories_outlined,
            activeIcon: Icons.auto_stories_rounded,
            label: l.expertStudio,
            child: const ExpertStudioScreen(),
            badge: null,
          ),
          (
            icon: Icons.video_call_outlined,
            activeIcon: Icons.video_call_rounded,
            label: l.expertConsultations,
            child: const ExpertConsultationsScreen(),
            badge: null,
          ),
          (
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: l.navProfile,
            child: const StaffProfileScreen(),
            badge: null,
          ),
        ],
      _ => [
          (
            icon: Icons.space_dashboard_outlined,
            activeIcon: Icons.space_dashboard_rounded,
            label: l.adminOverview,
            child: const AdminHomeScreen(),
            badge: null,
          ),
          (
            icon: Icons.verified_user_outlined,
            activeIcon: Icons.verified_user_rounded,
            label: l.adminApprovals,
            child: const AdminApprovalsScreen(),
            badge: ref.watch(adminOverviewProvider).value
                ?.pendingApprovals,
          ),
          (
            icon: Icons.people_outline_rounded,
            activeIcon: Icons.people_rounded,
            label: l.navUsers,
            child: const AdminUsersScreen(),
            badge: null,
          ),
          (
            icon: Icons.monitor_heart_outlined,
            activeIcon: Icons.monitor_heart_rounded,
            label: l.adminMonitor,
            child: const AdminMonitorScreen(),
            badge: null,
          ),
          (
            icon: Icons.tune_rounded,
            activeIcon: Icons.tune_rounded,
            label: l.adminSystem,
            child: const AdminSystemScreen(),
            badge: null,
          ),
        ],
    };
