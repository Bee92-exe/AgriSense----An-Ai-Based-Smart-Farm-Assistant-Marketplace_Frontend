import 'package:flutter/material.dart';
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
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../staff/staff_design.dart';
import '../staff/staff_widgets.dart';
import 'vendor_screens.dart';

/// The selected tab of the vendor shell. A notifier rather than shell-local
/// state so the dashboard's quick actions can send the vendor to the queue that
/// needs them, instead of duplicating those screens in a stack.
final vendorTabProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// The vendor's money and customer book, fetched together so the business tab
/// and the home summary cannot disagree.
final vendorBusinessProvider = FutureProvider<VendorBusiness>(
  (ref) async => ref.watch(vendorRepositoryProvider).business(),
);

OpsTone orderTone(OrderStatus status) => switch (status) {
      OrderStatus.delivered => OpsTone.success,
      OrderStatus.rejected || OrderStatus.cancelled => OpsTone.danger,
      OrderStatus.pending => OpsTone.warning,
      _ => OpsTone.primary,
    };

/// The vendor's home. It answers three questions in order: is my shop allowed
/// to trade, what needs doing today, and how did this week go.
class VendorHomeScreen extends ConsumerWidget {
  const VendorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final user = ref.watch(currentUserProvider);
    final desk = ref.watch(vendorDeskProvider);
    final business = ref.watch(vendorBusinessProvider);
    final tab = ref.watch(vendorTabProvider);

    if (user == null) {
      return const Scaffold(body: LoadingState(rows: 3));
    }

    final shop = user.vendor?.shopName ?? l.roleVendor;
    final verified = user.vendor?.isVerified ?? false;

    return AppScreen(
      title: l.navDashboard,
      showBack: false,
      header: StaffHero(
        eyebrow: l.vendorConsoleEyebrow,
        title: shop,
        subtitle: l.vendorConsoleSubtitle,
        initials: user.initials,
        icon: Icons.storefront_rounded,
        onAvatarTap: () => tab.value = 4,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () {
              ref.invalidate(vendorDeskProvider);
              ref.invalidate(vendorBusinessProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        footer: Container(
          padding: const EdgeInsets.all(Space.sm),
          decoration: BoxDecoration(
            color: p.onPrimary.withValues(alpha: 0.10),
            borderRadius: Radii.fieldAll,
            border: Border.all(
              color: p.onPrimary.withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              Icon(
                verified ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                size: 18,
                color: p.onPrimary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  verified ? l.vendorVerified : l.vendorNotVerified,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.labelLarge?.copyWith(
                    color: p.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: Space.xs),
              for (var i = 0; i < 5; i++)
                Icon(
                  i < (user.vendor?.rating ?? 0).round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 15,
                  color: p.harvestContainer,
                ),
              const SizedBox(width: 4),
              Text(
                (user.vendor?.rating ?? 0).toStringAsFixed(1),
                style: context.texts.labelMedium?.copyWith(
                  color: p.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!verified) ...[
            StaffNotice(
              icon: Icons.hourglass_top_rounded,
              title: l.vendorNotVerified,
              body: l.vendorReviewPending,
              tone: p.harvestContainer,
            ),
            const SizedBox(height: Space.md),
          ],
          StaffSectionTitle(
            title: l.staffQuickActions,
            icon: Icons.bolt_rounded,
          ),
          StaffActionGrid(
            children: [
              StaffActionTile(
                icon: Icons.add_box_rounded,
                label: l.vendorAddProduct,
                onTap: () => tab.value = 1,
              ),
              StaffActionTile(
                icon: Icons.receipt_long_rounded,
                label: l.navOrders,
                badge: desk.value?.pendingOrders,
                onTap: () => tab.value = 2,
              ),
              StaffActionTile(
                icon: Icons.people_alt_rounded,
                label: l.vendorCustomerBook,
                onTap: () => tab.value = 3,
              ),
              StaffActionTile(
                icon: Icons.insights_rounded,
                label: l.vendorBusiness,
                tone: p.harvestContainer,
                onTap: () => tab.value = 3,
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          desk.when(
            loading: () => const LoadingState(rows: 3),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(vendorDeskProvider),
            ),
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                StaffKpiRow(
                  left: StaffKpi(
                    value: f.taka(data.revenueToday),
                    label: l.vendorTodayRevenue,
                    icon: Icons.payments_rounded,
                  ),
                  right: StaffKpi(
                    value: f.number(data.todayOrders),
                    label: l.vendorTodayOrders,
                    icon: Icons.shopping_bag_rounded,
                    tone: p.harvestContainer,
                  ),
                ),
                const SizedBox(height: Space.xs),
                StaffKpiRow(
                  left: StaffKpi(
                    value: f.number(data.pendingOrders),
                    label: l.vendorPendingOrders,
                    icon: Icons.hourglass_top_rounded,
                  ),
                  right: StaffKpi(
                    value: f.number(
                      data.lowStock.length + data.outOfStock.length,
                    ),
                    label: l.vendorLowStock,
                    icon: Icons.inventory_2_rounded,
                  ),
                ),
                const SizedBox(height: Space.lg),
                SectionHeader(
                  title: l.vendorWeekSales,
                  icon: Icons.show_chart_rounded,
                  actionLabel: l.actionSeeAll,
                  onAction: () => tab.value = 3,
                ),
                const SizedBox(height: Space.xs),
                business.when(
                  loading: () =>
                      const LoadingState(rows: 1, showHeader: false),
                  error: (error, _) => ErrorState(
                    body: staffErrorText(error, l),
                    onRetry: () => ref.invalidate(vendorBusinessProvider),
                  ),
                  data: (money) => AppCard(
                    child: StaffChart(
                      points: money.week,
                      labels: [
                        for (final point in money.week) f.weekday(point.day),
                      ],
                      valueLabel: f.taka(
                        money.week.last.value.round(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Space.lg),
                SectionHeader(
                  title: l.vendorLowStockTitle,
                  icon: Icons.warning_amber_rounded,
                  actionLabel: l.navProducts,
                  onAction: () => tab.value = 1,
                ),
                const SizedBox(height: Space.xs),
                if (data.lowStock.isEmpty && data.outOfStock.isEmpty)
                  AppCard(
                    child: Text(
                      l.vendorStockFine,
                      style: context.texts.bodyMedium,
                    ),
                  )
                else
                  for (final product in [
                    ...data.outOfStock,
                    ...data.lowStock,
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: AppCard(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Space.md,
                          vertical: Space.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.label(
                                  Localizations.localeOf(context).languageCode,
                                ),
                                style: context.texts.titleSmall,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: Space.xs),
                            OpsPill(
                              label: product.stock == 0
                                  ? l.vendorOutOfStock
                                  : l.vendorStockLeft(
                                      f.number(product.stock),
                                    ),
                              tone: product.stock == 0
                                  ? OpsTone.danger
                                  : OpsTone.warning,
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: Space.lg),
                SectionHeader(
                  title: l.vendorRecentOrders,
                  icon: Icons.receipt_long_rounded,
                  actionLabel: l.navOrders,
                  onAction: () => tab.value = 2,
                ),
                const SizedBox(height: Space.xs),
                if (data.orders.isEmpty)
                  AppCard(
                    child: Text(
                      l.vendorNoOrders,
                      style: context.texts.bodyMedium,
                    ),
                  )
                else
                  for (final order in data.orders.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: AppCard(
                        padding: const EdgeInsets.all(Space.sm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                StaffAvatar(
                                  icon: Icons.person_rounded,
                                  size: 38,
                                ),
                                const SizedBox(width: Space.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.buyerName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.texts.titleSmall,
                                      ),
                                      Text(
                                        order.order.orderNo,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: context.texts.bodySmall
                                            ?.copyWith(
                                          color: p.onSurfaceMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: Space.xxs),
                            // Status and total share a run so a long Bangla
                            // status ("বাতিল করা হয়েছে") drops to its own line
                            // on a 320dp phone instead of overflowing the row.
                            Wrap(
                              spacing: Space.xs,
                              runSpacing: Space.xxs,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                OpsPill(
                                  label: order.order.status.label(l),
                                  tone: orderTone(order.order.status),
                                ),
                                Text(
                                  f.taka(order.order.totalAmount),
                                  style: context.texts.titleSmall,
                                ),
                              ],
                            ),
                          ],
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

/// The vendor's CRM and money tab. Two modes under one roof because they answer
/// the same question — who is buying, and is this shop making money — and a
/// sixth bottom tab would crowd the bar.
class VendorBusinessScreen extends ConsumerStatefulWidget {
  const VendorBusinessScreen({super.key});

  @override
  ConsumerState<VendorBusinessScreen> createState() =>
      _VendorBusinessScreenState();
}

class _VendorBusinessScreenState extends ConsumerState<VendorBusinessScreen> {
  int _mode = 0;
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final async = ref.watch(vendorBusinessProvider);

    return AppScreen(
      title: l.vendorBusiness,
      showBack: false,
      header: StaffTabHeader(
        title: l.vendorBusiness,
        subtitle: l.vendorBusinessSubtitle,
        icon: Icons.insights_rounded,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(vendorBusinessProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: async.when(
        loading: () => const LoadingState(rows: 4),
        error: (error, _) => ErrorState(
          body: staffErrorText(error, l),
          onRetry: () => ref.invalidate(vendorBusinessProvider),
        ),
        data: (money) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OpsFilters(
              labels: [l.vendorCustomerBook, l.vendorMoney],
              index: _mode,
              onChanged: (i) => setState(() => _mode = i),
            ),
            const SizedBox(height: Space.md),
            if (_mode == 0) _customers(context, money) else _money(context, money),
          ],
        ),
      ),
    );
  }

  Widget _customers(BuildContext context, VendorBusiness money) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final needle = _query.trim();

    final customers = money.customers
        .where(
          (c) =>
              needle.isEmpty ||
              c.name.contains(needle) ||
              c.mobile.contains(needle) ||
              c.district.contains(needle),
        )
        .toList(growable: false);

    final followUps =
        money.customers.where((c) => c.followUp).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaffKpiRow(
          left: StaffKpi(
            value: f.number(money.customers.length),
            label: l.vendorCustomers,
            icon: Icons.people_alt_rounded,
          ),
          right: StaffKpi(
            value: f.number(money.repeatCustomers),
            label: l.vendorRepeatCustomers,
            icon: Icons.repeat_rounded,
            tone: p.harvestContainer,
          ),
        ),
        const SizedBox(height: Space.md),
        TextField(
          controller: _search,
          textInputAction: TextInputAction.search,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            labelText: l.vendorCustomerSearch,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    tooltip: l.actionClose,
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
          ),
        ),
        if (followUps.isNotEmpty) ...[
          const SizedBox(height: Space.md),
          StaffNotice(
            icon: Icons.notifications_active_rounded,
            title: l.vendorFollowUpCount(f.number(followUps.length)),
            body: l.vendorFollowUpBody,
            tone: p.harvestContainer,
          ),
        ],
        const SizedBox(height: Space.md),
        if (customers.isEmpty)
          EmptyState(
            icon: Icons.person_search_rounded,
            title: l.vendorNoCustomers,
            body: l.vendorNoCustomersBody,
          )
        else
          for (final customer in customers)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xs),
              child: _CustomerCard(
                customer: customer,
                onTap: () => _openCustomer(customer),
              ),
            ),
      ],
    );
  }

  Widget _money(BuildContext context, VendorBusiness money) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StaffKpiRow(
          left: StaffKpi(
            value: f.taka(money.revenue30),
            label: l.vendorRevenue30,
            icon: Icons.payments_rounded,
          ),
          right: StaffKpi(
            value: f.taka(money.profit30),
            label: l.vendorProfit30,
            icon: Icons.trending_up_rounded,
            tone: p.harvestContainer,
          ),
        ),
        const SizedBox(height: Space.xs),
        StaffKpiRow(
          left: StaffKpi(
            value: f.taka(money.commission30),
            label: l.vendorCommission,
            icon: Icons.account_balance_rounded,
          ),
          right: StaffKpi(
            value: f.taka(money.pendingPayout),
            label: l.vendorPendingPayout,
            icon: Icons.savings_rounded,
            tone: p.harvestContainer,
          ),
        ),
        const SizedBox(height: Space.lg),
        SectionHeader(
          title: l.vendorWeekSales,
          icon: Icons.show_chart_rounded,
        ),
        const SizedBox(height: Space.xs),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StaffChart(
                points: money.week,
                labels: [for (final point in money.week) f.weekday(point.day)],
                valueLabel: f.taka(money.week.last.value.round()),
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      value: f.number(money.storeVisits),
                      label: l.vendorStoreVisits,
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      value: f.percentFromFraction(money.conversion / 100),
                      label: l.vendorConversion,
                    ),
                  ),
                  Expanded(
                    child: _MiniStat(
                      value: f.number(money.orders30),
                      label: l.vendorOrders30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        SectionHeader(
          title: l.vendorTopProducts,
          icon: Icons.local_fire_department_rounded,
        ),
        const SizedBox(height: Space.xs),
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < money.topProducts.length; i++)
                StaffProgress(
                  label: money.topProducts[i].name,
                  value: f.taka(money.topProducts[i].revenue),
                  ratio: money.topProducts[i].units /
                      (money.topProducts.first.units == 0
                          ? 1
                          : money.topProducts.first.units),
                  trailing: l.vendorUnits(
                    f.number(money.topProducts[i].units),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Space.lg),
        SectionHeader(
          title: l.vendorPayouts,
          icon: Icons.account_balance_wallet_rounded,
        ),
        const SizedBox(height: Space.xs),
        AppCard(
          child: Column(
            children: [
              for (final payout in money.payouts)
                ListRow(
                  title: f.taka(payout.amount),
                  subtitle: f.shortDate(payout.at),
                  leading: Icon(
                    Icons.check_circle_rounded,
                    color: p.success,
                  ),
                  trailing: OpsPill(
                    label: l.vendorPayoutPaid,
                    tone: OpsTone.success,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openCustomer(VendorCustomer customer) async {
    final changed = await showStaffSheet<bool>(
      context,
      title: customer.name,
      child: _CustomerSheet(customer: customer),
    );
    if (changed == true) {
      ref.invalidate(vendorBusinessProvider);
      ref.invalidate(vendorDeskProvider);
    }
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: context.texts.titleSmall,
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.texts.labelSmall?.copyWith(color: p.onSurfaceMuted),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  const _CustomerCard({required this.customer, required this.onTap});

  final VendorCustomer customer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final (label, tone) = customerSegment(l, customer.segment);

    return AppCard(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaffAvatar(
            initials: staffInitials(customer.name),
            verified: customer.orders >= 4,
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleSmall,
                      ),
                    ),
                    if (customer.followUp)
                      Icon(
                        Icons.notifications_active_rounded,
                        size: 16,
                        color: p.harvest,
                      ),
                  ],
                ),
                Text(
                  '${customer.district} · '
                  '${l.vendorOrdersCount(f.number(customer.orders))}',
                  style: context.texts.bodySmall
                      ?.copyWith(color: p.onSurfaceMuted),
                ),
                const SizedBox(height: Space.xxs),
                Wrap(
                  spacing: Space.xs,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OpsPill(label: label, tone: tone),
                    Text(
                      f.taka(customer.totalSpent),
                      style: context.texts.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      f.relative(customer.lastOrderAt),
                      style: context.texts.labelSmall
                          ?.copyWith(color: p.onSurfaceMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.onSurfaceMuted),
        ],
      ),
    );
  }

}

/// The customer segment vocabulary, kept in one place so the pill and the
/// filter cannot drift.
(String, OpsTone) customerSegment(AppL10n l, String segment) => switch (segment) {
      'loyal' => (l.vendorSegmentLoyal, OpsTone.success),
      'repeat' => (l.vendorSegmentRepeat, OpsTone.primary),
      'atRisk' => (l.vendorSegmentAtRisk, OpsTone.danger),
      _ => (l.vendorSegmentNew, OpsTone.warning),
    };

class _CustomerSheet extends ConsumerStatefulWidget {
  const _CustomerSheet({required this.customer});

  final VendorCustomer customer;

  @override
  ConsumerState<_CustomerSheet> createState() => _CustomerSheetState();
}

class _CustomerSheetState extends ConsumerState<_CustomerSheet> {
  late final TextEditingController _note =
      TextEditingController(text: widget.customer.note ?? '');
  late bool _followUp = widget.customer.followUp;
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final customer = widget.customer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            StaffAvatar(initials: staffInitials(customer.name), size: 52),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.name, style: context.texts.titleMedium),
                  Text(
                    '${customer.mobile} · ${customer.district}',
                    style: context.texts.bodySmall
                        ?.copyWith(color: p.onSurfaceMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        AppCard(
          child: Column(
            children: [
              StaffInfoRow(
                icon: Icons.shopping_bag_rounded,
                label: l.navOrders,
                value: f.number(customer.orders),
              ),
              StaffInfoRow(
                icon: Icons.payments_rounded,
                label: l.vendorLifetimeValue,
                value: f.taka(customer.totalSpent),
              ),
              StaffInfoRow(
                icon: Icons.schedule_rounded,
                label: l.vendorLastOrder,
                value: f.shortDate(customer.lastOrderAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
        Wrap(
          spacing: Space.xs,
          runSpacing: Space.xs,
          children: [
            AppButton(
              label: l.staffCall,
              icon: Icons.call_rounded,
              tone: AppButtonTone.secondary,
              expand: false,
              onPressed: () => _comingSoon(l),
            ),
            AppButton(
              label: l.staffMessage,
              icon: Icons.sms_rounded,
              tone: AppButtonTone.secondary,
              expand: false,
              onPressed: () => _comingSoon(l),
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        TextField(
          controller: _note,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: l.vendorCustomerNote,
            hintText: l.vendorNoteHint,
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          value: _followUp,
          onChanged: (value) => setState(() => _followUp = value),
          title: Text(l.vendorMarkFollowUp),
          subtitle: Text(
            l.vendorFollowUpHint,
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
        ),
        const SizedBox(height: Space.xs),
        AppButton(
          label: l.actionSave,
          isLoading: _saving,
          onPressed: () => _save(ref),
        ),
        const SizedBox(height: Space.xs),
        AppButton(
          label: l.actionClose,
          tone: AppButtonTone.quiet,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  Future<void> _save(WidgetRef ref) async {
    final l = AppL10n.of(context);
    setState(() => _saving = true);
    try {
      final repo = ref.read(vendorRepositoryProvider);
      await repo.saveCustomerNote(widget.customer.id, _note.text.trim());
      final updated =
          await repo.setFollowUp(widget.customer.id, _followUp);
      if (!mounted) return;
      setState(() => _followUp = updated.followUp);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.vendorNoteSaved)),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }

  void _comingSoon(AppL10n l) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.staffComingSoon)),
    );
  }

}
