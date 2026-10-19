import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/states.dart';
import '../../data/models/enums.dart';
import '../../data/models/growth.dart';
import '../../data/models/ops.dart';
import '../../data/models/product.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../staff/staff_design.dart';
import '../staff/staff_profile_screen.dart';
import '../staff/staff_widgets.dart';
import 'admin_news_screens.dart';
import 'admin_providers.dart';
import 'admin_screens.dart';

final adminTabProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.onDispose(notifier.dispose);
  return notifier;
});

final adminOverviewProvider = FutureProvider<AdminOverview>(
  (ref) async => ref.watch(adminRepositoryProvider).overview(),
);

final adminProductsProvider = FutureProvider<List<AdminProduct>>(
  (ref) async => ref.watch(adminRepositoryProvider).products(),
);

final adminOrdersProvider = FutureProvider<List<Order>>(
  (ref) async => ref.watch(adminRepositoryProvider).allOrders(),
);

final adminContentProvider = FutureProvider<List<AdminContent>>(
  (ref) async => ref.watch(adminRepositoryProvider).content(),
);

final adminSettingsProvider = FutureProvider<AdminSettings>(
  (ref) async => ref.watch(adminRepositoryProvider).settings(),
);

/// The control room. One screen answers "is the platform healthy, and what is
/// waiting on me" before the admin has to open a single list.
class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final user = ref.watch(currentUserProvider);
    final overview = ref.watch(adminOverviewProvider);
    final vendors = ref.watch(adminVendorsProvider('pending'));
    final users = ref.watch(adminUsersProvider(
      (query: '', role: null, status: AccountStatus.pending),
    ));
    final logs = ref.watch(adminLogsProvider(null));
    final sources = ref.watch(adminSourcesProvider);
    final tab = ref.watch(adminTabProvider);

    if (user == null) {
      return const Scaffold(body: LoadingState(rows: 3));
    }

    final pendingCount = (vendors.value?.length ?? 0) +
        (users.value?.length ?? 0);
    final failedSources = sources.value
            ?.where((s) => s.active && s.lastRunOk == false)
            .length ??
        0;

    return AppScreen(
      title: l.adminOverview,
      showBack: false,
      header: StaffHero(
        eyebrow: l.adminConsoleEyebrow,
        title: user.name,
        subtitle: l.adminConsoleSubtitle,
        initials: user.initials,
        icon: Icons.admin_panel_settings_rounded,
        onAvatarTap: () => tab.value = 4,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () {
              ref.invalidate(adminOverviewProvider);
              ref.invalidate(adminVendorsProvider);
              ref.invalidate(adminUsersProvider);
              ref.invalidate(adminLogsProvider);
              ref.invalidate(adminSourcesProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        footer: Builder(
          builder: (context) {
            final ink = p.onPrimary;
            return Row(
              children: [
                Icon(
                  pendingCount == 0
                      ? Icons.check_circle_rounded
                      : Icons.pending_actions_rounded,
                  size: 18,
                  color: ink,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pendingCount == 0
                        ? l.adminAllClear
                        : l.adminPendingApprovalsCount(
                            f.number(pendingCount),
                          ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.texts.labelLarge?.copyWith(
                      color: ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  l.adminReviewWithin24h,
                  style: context.texts.labelSmall?.copyWith(
                    color: ink.withValues(alpha: 0.8),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StaffSectionTitle(
            title: l.staffQuickActions,
            icon: Icons.bolt_rounded,
          ),
          StaffActionGrid(
            children: [
              StaffActionTile(
                icon: Icons.verified_user_rounded,
                label: l.adminApprovals,
                badge: pendingCount,
                onTap: () => tab.value = 1,
              ),
              StaffActionTile(
                icon: Icons.people_alt_rounded,
                label: l.navUsers,
                onTap: () => tab.value = 2,
              ),
              StaffActionTile(
                icon: Icons.storefront_rounded,
                label: l.adminMonitor,
                tone: p.harvestContainer,
                onTap: () => tab.value = 3,
              ),
              StaffActionTile(
                icon: Icons.tune_rounded,
                label: l.adminSystem,
                onTap: () => tab.value = 4,
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          overview.when(
            loading: () => const LoadingState(rows: 3),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(adminOverviewProvider),
            ),
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StaffKpiRow(
                  left: StaffKpi(
                    value: f.taka(data.gmv30),
                    label: l.adminGmv,
                    icon: Icons.stacked_line_chart_rounded,
                    trend: l.adminLast30Days,
                  ),
                  right: StaffKpi(
                    value: f.taka(data.commission30),
                    label: l.adminCommissionEarned,
                    icon: Icons.account_balance_rounded,
                    tone: p.harvestContainer,
                  ),
                ),
                const SizedBox(height: Space.xs),
                StaffKpiRow(
                  left: StaffKpi(
                    value: f.number(data.activeUsers),
                    label: l.adminActiveUsers,
                    icon: Icons.groups_rounded,
                  ),
                  right: StaffKpi(
                    value: f.number(data.newUsers7),
                    label: l.adminNewUsers,
                    icon: Icons.person_add_alt_1_rounded,
                    tone: p.harvestContainer,
                  ),
                ),
                const SizedBox(height: Space.lg),
                SectionHeader(
                  title: l.adminPlatformHealth,
                  icon: Icons.monitor_heart_rounded,
                ),
                const SizedBox(height: Space.xs),
                AppCard(
                  child: StaffChart(
                    points: data.week,
                    labels: [for (final point in data.week) f.weekday(point.day)],
                    valueLabel: f.taka(data.week.last.value.round()),
                  ),
                ),
                const SizedBox(height: Space.lg),
                SectionHeader(
                  title: l.adminApprovalQueue,
                  icon: Icons.fact_check_rounded,
                  actionLabel: l.actionSeeAll,
                  onAction: () => tab.value = 1,
                ),
                const SizedBox(height: Space.xs),
                if (pendingCount == 0)
                  AppCard(
                    child: Text(
                      l.adminNoApprovals,
                      style: context.texts.bodyMedium,
                    ),
                  )
                else
                  AppCard(
                    child: Column(
                      children: [
                        for (final vendor in
                            (vendors.value ?? const <AdminVendor>[]).take(2))
                          ListRow(
                            leading: StaffAvatar(
                              icon: Icons.storefront_rounded,
                              size: 36,
                            ),
                            title: vendor.shopName,
                            subtitle: '${vendor.ownerName} · '
                                '${l.adminVendorApplication}',
                            trailing: OpsPill(
                              label: l.accountStatusPending,
                              tone: OpsTone.warning,
                            ),
                          ),
                        for (final account in
                            (users.value ?? const <PlatformUser>[]).take(2))
                          ListRow(
                            leading: StaffAvatar(
                              icon: Icons.person_rounded,
                              size: 36,
                            ),
                            title: account.name,
                            subtitle:
                                '${account.role.label(l)} · '
                                '${l.adminAccountApplication}',
                            trailing: OpsPill(
                              label: l.accountStatusPending,
                              tone: OpsTone.warning,
                            ),
                          ),
                        StaffLinkRow(
                          icon: Icons.arrow_forward_rounded,
                          label: l.adminOpenApprovals,
                          onTap: () => tab.value = 1,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: Space.lg),
                SectionHeader(
                  title: l.adminNeedsAttention,
                  icon: Icons.warning_amber_rounded,
                ),
                const SizedBox(height: Space.xs),
                if (failedSources == 0)
                  StaffNotice(
                    icon: Icons.check_circle_rounded,
                    title: l.adminAllSystemsOk,
                    body: l.adminAllSystemsOkBody,
                  )
                else
                  StaffNotice(
                    icon: Icons.cloud_off_rounded,
                    title: l.adminSourceIssues(f.number(failedSources)),
                    body: l.adminSourceIssuesBody,
                    tone: p.harvestContainer,
                    action: StaffLinkRow(
                      icon: Icons.arrow_forward_rounded,
                      label: l.adminManageSources,
                      onTap: () => tab.value = 4,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          SectionHeader(
            title: l.adminRecentActivity,
            icon: Icons.history_rounded,
            actionLabel: l.actionSeeAll,
            onAction: () => tab.value = 4,
          ),
          const SizedBox(height: Space.xs),
          logs.when(
            loading: () => const LoadingState(rows: 1, showHeader: false),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(adminLogsProvider),
            ),
            data: (items) => AppCard(
              child: Column(
                children: [
                  for (final entry in items.take(3))
                    ListRow(
                      leading: Icon(
                        _logIcon(entry.type),
                        size: 20,
                        color: p.onSurfaceMuted,
                      ),
                      title: entry.message,
                      subtitle:
                          '${l.opsLogType(entry.type)} · '
                          '${f.relative(entry.at)}',
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _logIcon(OpsLogType type) => switch (type) {
        OpsLogType.collection => Icons.cloud_download_rounded,
        OpsLogType.voice => Icons.mic_rounded,
        OpsLogType.aiFallback => Icons.smart_toy_rounded,
        OpsLogType.audit => Icons.admin_panel_settings_rounded,
        OpsLogType.system => Icons.memory_rounded,
      };
}

/// Every account waiting for a person to say yes. Vendors and experts are the
/// reason the screen exists, but the same queue approves a farmer too, so the
/// admin never has to remember which list a pending account is in.
class AdminApprovalsScreen extends ConsumerStatefulWidget {
  const AdminApprovalsScreen({super.key});

  @override
  ConsumerState<AdminApprovalsScreen> createState() =>
      _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends ConsumerState<AdminApprovalsScreen> {
  int _filter = 0;
  String? _busyId;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final vendors = ref.watch(adminVendorsProvider('pending'));
    final users = ref.watch(adminUsersProvider(
      (query: '', role: null, status: AccountStatus.pending),
    ));

    final pendingVendors = _filter == 0 || _filter == 1
        ? vendors.value ?? const <AdminVendor>[]
        : const <AdminVendor>[];
    final pendingUsers = users.value
            ?.where((u) => _filter != 0 || u.role != Role.vendor)
            .where((u) => _filter == 0 || u.role.wire == _filterRole)
            .toList(growable: false) ??
        const <PlatformUser>[];

    final loading = vendors.isLoading || users.isLoading;
    final total = pendingVendors.length + pendingUsers.length;

    return AppScreen(
      title: l.adminApprovals,
      showBack: false,
      header: StaffTabHeader(
        title: l.adminApprovals,
        subtitle: l.adminApprovalBody,
        icon: Icons.verified_user_rounded,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () {
              ref.invalidate(adminVendorsProvider);
              ref.invalidate(adminUsersProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StaffNotice(
            icon: Icons.timer_rounded,
            title: l.adminSlaTitle,
            body: l.adminSlaBody,
            tone: p.harvestContainer,
          ),
          const SizedBox(height: Space.md),
          OpsFilters(
            labels: [
              l.filterAll,
              l.adminVendorsTab,
              l.roleExpert,
              l.roleFarmer,
            ],
            index: _filter,
            onChanged: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: Space.md),
          if (loading)
            const LoadingState(rows: 4)
          else if (total == 0)
            EmptyState(
              icon: Icons.task_alt_rounded,
              title: l.adminNoApprovals,
              body: l.adminNoApprovalsBody,
            )
          else ...[
            if (pendingVendors.isNotEmpty) ...[
              StaffSectionTitle(
                title: l.adminVendorApplications,
                icon: Icons.storefront_rounded,
                count: pendingVendors.length,
              ),
              for (final vendor in pendingVendors)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.xs),
                  child: _ApprovalCard(
                    icon: Icons.storefront_rounded,
                    title: vendor.shopName,
                    lines: [
                      '${vendor.ownerName} · ${vendor.ownerMobile}',
                      '${vendor.district} · ${l.adminLicense}: '
                          '${vendor.licenseNo}',
                      l.adminSubmitted(f.shortDate(vendor.submittedAt)),
                    ],
                    busy: _busyId == 'v-${vendor.id}',
                    disabled: _busyId != null,
                    onApprove: () => _approveVendor(vendor),
                    onReject: () => _rejectVendor(vendor),
                  ),
                ),
              const SizedBox(height: Space.sm),
            ],
            if (pendingUsers.isNotEmpty) ...[
              StaffSectionTitle(
                title: l.adminAccountApplications,
                icon: Icons.people_alt_rounded,
                count: pendingUsers.length,
              ),
              for (final account in pendingUsers)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.xs),
                  child: _ApprovalCard(
                    icon: account.role == Role.vendor
                        ? Icons.storefront_rounded
                        : account.role == Role.expert
                            ? Icons.school_rounded
                            : Icons.agriculture_rounded,
                    title: account.name,
                    badge: account.role.label(l),
                    lines: [
                      '${account.mobile} · ${account.district}',
                      l.adminSubmitted(f.shortDate(account.joinedAt)),
                    ],
                    busy: _busyId == 'u-${account.id}',
                    disabled: _busyId != null,
                    onApprove: () => _setUser(account, true),
                    onReject: () => _setUser(account, false),
                  ),
                ),
              const SizedBox(height: Space.sm),
            ],
            Text(
              l.adminPendingTotal(f.number(total)),
              textAlign: TextAlign.center,
              style: context.texts.labelSmall?.copyWith(color: p.onSurfaceMuted),
            ),
          ],
          const SizedBox(height: Space.sm),
          Text(
            l.adminApprovalFooter,
            textAlign: TextAlign.center,
            style: context.texts.labelSmall?.copyWith(color: p.onSurfaceMuted),
          ),
        ],
      ),
    );
  }

  String? get _filterRole => switch (_filter) {
        1 => Role.vendor.wire,
        2 => Role.expert.wire,
        3 => Role.farmer.wire,
        _ => null,
      };

  Future<void> _approveVendor(AdminVendor vendor) async {
    final l = AppL10n.of(context);
    setState(() => _busyId = 'v-${vendor.id}');
    try {
      await ref.read(adminRepositoryProvider).verifyVendor(vendor.id);
      _refresh();
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.adminApprovedNow)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }

  Future<void> _rejectVendor(AdminVendor vendor) async {
    final l = AppL10n.of(context);
    final reason = await askStaffReason(
      context,
      title: l.adminRejectTitle,
      hint: l.adminReasonHint,
      actionLabel: l.adminReject,
    );
    if (reason == null || !mounted) return;
    setState(() => _busyId = 'v-${vendor.id}');
    try {
      await ref
          .read(adminRepositoryProvider)
          .rejectVendor(vendor.id, reason: reason);
      _refresh();
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.adminRejectedNow)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }

  Future<void> _setUser(PlatformUser account, bool approve) async {
    final l = AppL10n.of(context);
    String? reason;
    if (!approve) {
      reason = await askStaffReason(
        context,
        title: l.adminRejectTitle,
        hint: l.adminReasonHint,
        actionLabel: l.adminReject,
      );
      if (reason == null || !mounted) return;
    }
    setState(() => _busyId = 'u-${account.id}');
    try {
      await ref.read(adminRepositoryProvider).setUserStatus(
            account.id,
            approve ? AccountStatus.active : AccountStatus.removed,
            reason: reason,
          );
      _refresh();
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve ? l.adminApprovedNow : l.adminRejectedNow,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }

  void _refresh() {
    ref.invalidate(adminVendorsProvider);
    ref.invalidate(adminUsersProvider);
    ref.invalidate(adminOverviewProvider);
    ref.invalidate(adminLogsProvider);
  }
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.icon,
    required this.title,
    required this.lines,
    required this.busy,
    required this.disabled,
    required this.onApprove,
    required this.onReject,
    this.badge,
  });

  final IconData icon;
  final String title;
  final List<String> lines;
  final bool busy;
  final bool disabled;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffAvatar(icon: icon),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.texts.titleSmall),
                    for (final line in lines)
                      Text(
                        line,
                        style: context.texts.bodySmall
                            ?.copyWith(color: p.onSurfaceMuted),
                      ),
                  ],
                ),
              ),
              if (badge != null)
                OpsPill(label: badge!, tone: OpsTone.primary),
            ],
          ),
          const SizedBox(height: Space.xs),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l.adminApprove,
                  icon: Icons.check_rounded,
                  isLoading: busy,
                  isEnabled: !disabled,
                  onPressed: onApprove,
                ),
              ),
              const SizedBox(width: Space.xs),
              Expanded(
                child: AppButton(
                  label: l.adminReject,
                  tone: AppButtonTone.danger,
                  isEnabled: !disabled,
                  onPressed: onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Catalogue, orders and content in one read-only-by-default monitor. The admin
/// can take a listing or a story down; they can never buy, and the note at the
/// top of the order list says so.
class AdminMonitorScreen extends ConsumerStatefulWidget {
  const AdminMonitorScreen({super.key});

  @override
  ConsumerState<AdminMonitorScreen> createState() => _AdminMonitorScreenState();
}

class _AdminMonitorScreenState extends ConsumerState<AdminMonitorScreen> {
  int _mode = 0;
  int _orderFilter = 0;
  String? _busyId;

  static const List<OrderStatus?> _orderStatus = [
    null,
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final products = ref.watch(adminProductsProvider);
    final orders = ref.watch(adminOrdersProvider);
    final content = ref.watch(adminContentProvider);

    return AppScreen(
      title: l.adminMonitor,
      showBack: false,
      header: StaffTabHeader(
        title: l.adminMonitor,
        subtitle: l.adminMonitorSubtitle,
        icon: Icons.storefront_rounded,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () {
              ref.invalidate(adminProductsProvider);
              ref.invalidate(adminOrdersProvider);
              ref.invalidate(adminContentProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OpsFilters(
            labels: [l.adminOrders, l.adminCatalog, l.adminContent],
            index: _mode,
            onChanged: (i) => setState(() => _mode = i),
          ),
          const SizedBox(height: Space.md),
          if (_mode == 0) ...[
            StaffNotice(
              icon: Icons.visibility_rounded,
              title: l.adminReadOnly,
              body: l.adminReadOnlyBody,
              tone: p.surfaceSunken,
            ),
            const SizedBox(height: Space.sm),
            OpsFilters(
              labels: [
                l.filterAll,
                l.orderStatusPending,
                l.orderStatusConfirmed,
                l.orderStatusShipped,
                l.orderStatusDelivered,
              ],
              index: _orderFilter,
              onChanged: (i) => setState(() => _orderFilter = i),
            ),
            const SizedBox(height: Space.sm),
            orders.when(
              loading: () => const LoadingState(rows: 4),
              error: (error, _) => ErrorState(
                body: staffErrorText(error, l),
                onRetry: () => ref.invalidate(adminOrdersProvider),
              ),
              data: (items) {
                final wanted = _orderStatus[_orderFilter];
                final shown = wanted == null
                    ? items
                    : items
                        .where((o) => o.status == wanted)
                        .toList(growable: false);
                if (shown.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: l.vendorNoOrders,
                    body: l.vendorNoOrdersBody,
                  );
                }
                return Column(
                  children: [
                    for (final order in shown)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Space.xs),
                        child: _AdminOrderCard(order: order),
                      ),
                  ],
                );
              },
            ),
          ] else if (_mode == 1) ...[
            StaffNotice(
              icon: Icons.inventory_2_rounded,
              title: l.adminCatalogNote,
              body: l.adminCatalogNoteBody,
            ),
            const SizedBox(height: Space.sm),
            products.when(
              loading: () => const LoadingState(rows: 4),
              error: (error, _) => ErrorState(
                body: staffErrorText(error, l),
                onRetry: () => ref.invalidate(adminProductsProvider),
              ),
              data: (items) => Column(
                children: [
                  for (final product in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: _AdminProductCard(
                        product: product,
                        busy: _busyId == product.id,
                        onToggle: () => _toggleProduct(product),
                      ),
                    ),
                ],
              ),
            ),
          ] else ...[
            StaffNotice(
              icon: Icons.article_rounded,
              title: l.adminContentNote,
              body: l.adminContentNoteBody,
            ),
            const SizedBox(height: Space.sm),
            content.when(
              loading: () => const LoadingState(rows: 4),
              error: (error, _) => ErrorState(
                body: staffErrorText(error, l),
                onRetry: () => ref.invalidate(adminContentProvider),
              ),
              data: (items) => Column(
                children: [
                  for (final item in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: _AdminContentCard(
                        item: item,
                        busy: _busyId == item.id,
                        onToggle: () => _toggleContent(item),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleProduct(AdminProduct product) async {
    final l = AppL10n.of(context);
    setState(() => _busyId = product.id);
    try {
      await ref
          .read(adminRepositoryProvider)
          .setProductHidden(product.id, !product.hidden);
      ref.invalidate(adminProductsProvider);
      ref.invalidate(adminLogsProvider);
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.adminProductUpdated)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }

  Future<void> _toggleContent(AdminContent item) async {
    final l = AppL10n.of(context);
    setState(() => _busyId = item.id);
    try {
      await ref
          .read(adminRepositoryProvider)
          .setContentHidden(item.id, !item.hidden);
      ref.invalidate(adminContentProvider);
      ref.invalidate(adminLogsProvider);
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.adminContentUpdated)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _busyId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StaffAvatar(icon: Icons.receipt_long_rounded, size: 36),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.orderNo, style: context.texts.titleSmall),
                    Text(
                      '${order.vendor.shopName} · '
                      '${f.dateTime(order.createdAt)}',
                      maxLines: 2,
                      style: context.texts.bodySmall
                          ?.copyWith(color: p.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              OpsPill(
                label: order.status.label(l),
                tone: switch (order.status) {
                  OrderStatus.delivered => OpsTone.success,
                  OrderStatus.rejected || OrderStatus.cancelled => OpsTone.danger,
                  OrderStatus.pending => OpsTone.warning,
                  _ => OpsTone.primary,
                },
              ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l.adminItems}: ${f.number(order.items.length)}',
                  style: context.texts.bodySmall,
                ),
              ),
              Text(
                f.taka(order.totalAmount),
                style: context.texts.titleSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminProductCard extends StatelessWidget {
  const _AdminProductCard({
    required this.product,
    required this.busy,
    required this.onToggle,
  });

  final AdminProduct product;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffAvatar(icon: Icons.inventory_2_rounded, size: 38),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.titleSmall,
                    ),
                    Text(
                      '${product.shopName} · '
                      '${l.productCategory(product.category)}',
                      maxLines: 2,
                      style: context.texts.bodySmall
                          ?.copyWith(color: p.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              if (product.hidden)
                OpsPill(label: l.adminHidden, tone: OpsTone.danger),
            ],
          ),
          const SizedBox(height: Space.xs),
          Row(
            children: [
              Text(
                f.taka(product.price),
                style: context.texts.titleSmall,
              ),
              const SizedBox(width: Space.xs),
              Text(
                l.vendorStockLeft(f.number(product.stock)),
                style: context.texts.bodySmall
                    ?.copyWith(color: p.onSurfaceMuted),
              ),
              const Spacer(),
              AppButton(
                label: product.hidden
                    ? l.adminShowProduct
                    : l.adminHideProduct,
                tone: product.hidden
                    ? AppButtonTone.secondary
                    : AppButtonTone.danger,
                expand: false,
                isLoading: busy,
                onPressed: onToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminContentCard extends StatelessWidget {
  const _AdminContentCard({
    required this.item,
    required this.busy,
    required this.onToggle,
  });

  final AdminContent item;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              OpsPill(
                label: item.kind == 'news' ? l.navNews : l.expertFeed,
                tone: OpsTone.neutral,
              ),
              const Spacer(),
              if (item.hidden)
                OpsPill(label: l.adminHidden, tone: OpsTone.danger),
            ],
          ),
          const SizedBox(height: Space.xxs),
          Text(item.title, style: context.texts.titleSmall),
          Text(
            '${item.author} · ${f.relative(item.publishedAt)}',
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
          const SizedBox(height: Space.xs),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppButton(
              label: item.hidden ? l.adminRestore : l.adminTakeDown,
              tone: item.hidden
                  ? AppButtonTone.secondary
                  : AppButtonTone.danger,
              expand: false,
              isLoading: busy,
              onPressed: onToggle,
            ),
          ),
        ],
      ),
    );
  }
}

/// Platform switches, the source console and the admin's own account. The
/// settings form is separate so its controllers are built after the async value
/// exists, never with an empty placeholder that the admin could save.
class AdminSystemScreen extends ConsumerWidget {
  const AdminSystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final settings = ref.watch(adminSettingsProvider);
    final user = ref.watch(currentUserProvider);

    return AppScreen(
      title: l.adminSystem,
      showBack: false,
      header: StaffTabHeader(
        title: l.adminSystem,
        subtitle: l.adminSystemSubtitle,
        icon: Icons.tune_rounded,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(adminSettingsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StaffSectionTitle(
            title: l.adminSettings,
            icon: Icons.settings_rounded,
          ),
          settings.when(
            loading: () => const LoadingState(rows: 3, showHeader: false),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(adminSettingsProvider),
            ),
            data: (value) => _SettingsForm(initial: value),
          ),
          const SizedBox(height: Space.lg),
          StaffSectionTitle(
            title: l.adminOperations,
            icon: Icons.cable_rounded,
          ),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.rss_feed_rounded, color: p.primary),
                  title: Text(l.navSources),
                  subtitle: Text(l.adminSourcesSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminSourcesScreen(),
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.history_rounded, color: p.primary),
                  title: Text(l.navLogs),
                  subtitle: Text(l.adminLogsSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminLogsScreen(),
                    ),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.verified_user_rounded, color: p.primary),
                  title: Text(l.adminVendorApprovals),
                  subtitle: Text(l.adminVendorApprovalsSubtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AdminVendorsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          if (user != null)
            AppCard(
              child: Row(
                children: [
                  StaffAvatar(initials: user.initials, size: 48),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: context.texts.titleSmall),
                        Text(
                          '${user.role.label(l)} · ${user.mobile}',
                          style: context.texts.bodySmall
                              ?.copyWith(color: p.onSurfaceMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l.profileTitle,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const StaffProfileScreen(
                          showBack: true,
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),
            ),
          const SizedBox(height: Space.lg),
          Text(
            l.profileVersion('1.0.0'),
            textAlign: TextAlign.center,
            style: context.texts.labelSmall?.copyWith(color: p.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

class _SettingsForm extends ConsumerStatefulWidget {
  const _SettingsForm({required this.initial});

  final AdminSettings initial;

  @override
  ConsumerState<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends ConsumerState<_SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _commission = TextEditingController(
    text: widget.initial.commissionPercent.toString(),
  );
  late final TextEditingController _phone =
      TextEditingController(text: widget.initial.supportPhone);
  late final TextEditingController _banner =
      TextEditingController(text: widget.initial.broadcastBanner);
  late bool _autoFarmers = widget.initial.autoApproveFarmers;
  late bool _maintenance = widget.initial.maintenance;
  bool _saving = false;

  @override
  void dispose() {
    _commission.dispose();
    _phone.dispose();
    _banner.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              children: [
                TextFormField(
                  controller: _commission,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                    LengthLimitingTextInputFormatter(2),
                  ],
                  decoration: InputDecoration(
                    labelText: l.adminCommissionPercent,
                    helperText: l.adminCommissionHint,
                    suffixText: '%',
                  ),
                  validator: (value) {
                    final parsed = int.tryParse((value ?? '').trim());
                    if (parsed == null || parsed < 0 || parsed > 30) {
                      return l.adminCommissionInvalid;
                    }
                    return null;
                  },
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _autoFarmers,
                  onChanged: (value) =>
                      setState(() => _autoFarmers = value),
                  title: Text(l.adminAutoApproveFarmers),
                  subtitle: Text(
                    l.adminAutoApproveFarmersHint,
                    style: context.texts.bodySmall
                        ?.copyWith(color: p.onSurfaceMuted),
                  ),
                ),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _maintenance,
                  onChanged: (value) =>
                      setState(() => _maintenance = value),
                  title: Text(l.adminMaintenance),
                  subtitle: Text(
                    l.adminMaintenanceHint,
                    style: context.texts.bodySmall
                        ?.copyWith(color: p.onSurfaceMuted),
                  ),
                ),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l.adminSupportPhone,
                  ),
                ),
                const SizedBox(height: Space.sm),
                TextFormField(
                  controller: _banner,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l.adminBroadcast,
                    hintText: l.adminBroadcastHint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
          AppButton(
            label: l.adminSaveSettings,
            isLoading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l = AppL10n.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(adminRepositoryProvider).saveSettings(
            AdminSettings(
              commissionPercent: int.parse(_commission.text.trim()),
              autoApproveFarmers: _autoFarmers,
              maintenance: _maintenance,
              supportPhone: _phone.text.trim(),
              broadcastBanner: _banner.text.trim(),
            ),
          );
      ref.invalidate(adminSettingsProvider);
      ref.invalidate(adminLogsProvider);
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.adminSettingsSaved)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }
}
