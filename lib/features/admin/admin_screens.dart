import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/states.dart';
import '../../data/models/enums.dart';
import '../../data/models/ops.dart';
import '../../data/providers.dart';
import '../../data/repositories/admin_repository.dart';
import '../../l10n/app_localizations.dart';
import '../staff/staff_design.dart';
import '../staff/staff_widgets.dart';
import 'admin_providers.dart';

OpsTone _verificationTone(String status) => switch (status) {
      'verified' => OpsTone.success,
      'rejected' || 'suspended' => OpsTone.danger,
      _ => OpsTone.warning,
    };

class AdminVendorsScreen extends ConsumerStatefulWidget {
  const AdminVendorsScreen({super.key});

  @override
  ConsumerState<AdminVendorsScreen> createState() => _AdminVendorsScreenState();
}

class _AdminVendorsScreenState extends ConsumerState<AdminVendorsScreen> {
  static const List<String?> _statuses = [
    null,
    'pending',
    'verified',
    'rejected',
    'suspended',
  ];

  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final status = _statuses[_filter];
    final async = ref.watch(adminVendorsProvider(status));

    return AppScreen(
      title: l.navVendors,
      showBack: false,
      header: StaffTabHeader(
        title: l.adminVendorApprovals,
        subtitle: l.adminVendorApprovalsSubtitle,
        icon: Icons.storefront_rounded,
        showBack: true,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(adminVendorsProvider(status)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OpsFilters(
            labels: [
              l.filterAll,
              l.vendorPendingReview,
              l.vendorVerified,
              l.vendorRejected,
              l.vendorSuspended,
            ],
            index: _filter,
            onChanged: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: Space.md),
          async.when(
            loading: () => const LoadingState(rows: 4),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(adminVendorsProvider(status)),
            ),
            data: (vendors) {
              if (vendors.isEmpty) {
                return EmptyState(
                  icon: Icons.storefront_rounded,
                  title: l.adminVendorEmpty,
                  body: l.adminVendorEmptyBody,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final vendor in vendors)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: _VendorApprovalCard(vendor: vendor),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VendorApprovalCard extends ConsumerStatefulWidget {
  const _VendorApprovalCard({required this.vendor});

  final AdminVendor vendor;

  @override
  ConsumerState<_VendorApprovalCard> createState() =>
      _VendorApprovalCardState();
}

class _VendorApprovalCardState extends ConsumerState<_VendorApprovalCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final vendor = widget.vendor;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Space.xs,
            runSpacing: Space.xxs,
            children: [
              Text(vendor.shopName, style: context.texts.titleSmall),
              OpsPill(
                label: l.vendorVerification(vendor.status),
                tone: _verificationTone(vendor.status),
              ),
            ],
          ),
          const SizedBox(height: Space.xxs),
          Text(
            '${vendor.ownerName} · ${vendor.ownerMobile}',
            style: context.texts.bodySmall,
          ),
          Text(
            '${vendor.district} · ${l.adminLicense}: ${vendor.licenseNo}',
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
          Text(
            l.adminSubmitted(f.shortDate(vendor.submittedAt)),
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
          if (vendor.reason != null) ...[
            const SizedBox(height: Space.xxs),
            Text(
              vendor.reason!,
              style: context.texts.bodySmall?.copyWith(color: p.error),
            ),
          ],
          const SizedBox(height: Space.xs),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              if (vendor.isPending)
                AppButton(
                  label: l.adminVerify,
                  tone: AppButtonTone.secondary,
                  expand: false,
                  isLoading: _busy,
                  onPressed: () => _verify(),
                ),
              if (vendor.isPending)
                AppButton(
                  label: l.adminReject,
                  tone: AppButtonTone.danger,
                  expand: false,
                  onPressed: _reject,
                ),
              if (vendor.isVerified)
                AppButton(
                  label: l.adminSuspend,
                  tone: AppButtonTone.danger,
                  expand: false,
                  onPressed: _suspend,
                ),
              if (!vendor.isPending && !vendor.isVerified)
                AppButton(
                  label: l.adminReinstate,
                  tone: AppButtonTone.secondary,
                  expand: false,
                  onPressed: () => _verify(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _verify() => _run(
        (repo) => repo.verifyVendor(widget.vendor.id),
      );

  Future<void> _suspend() async {
    final l = AppL10n.of(context);
    final reason = await askStaffReason(
      context,
      title: l.adminSuspendTitle,
      hint: l.adminReasonHint,
      actionLabel: l.adminSuspend,
    );
    if (reason == null) return;
    await _run((repo) => repo.suspendVendor(widget.vendor.id, reason: reason));
  }

  Future<void> _reject() async {
    final l = AppL10n.of(context);
    final reason = await askStaffReason(
      context,
      title: l.adminRejectTitle,
      hint: l.adminReasonHint,
      actionLabel: l.adminReject,
    );
    if (reason == null) return;
    await _run((repo) => repo.rejectVendor(widget.vendor.id, reason: reason));
  }

  Future<void> _run(Future<void> Function(AdminRepository repo) action) async {
    final l = AppL10n.of(context);
    setState(() => _busy = true);
    try {
      await action(ref.read(adminRepositoryProvider));
      ref.invalidate(adminVendorsProvider);
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.adminVendorUpdated)),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }
}

/// Account list with the three filters the spec names: text, role and status
/// (FR-50). Suspending asks for a reason, because the reason is what the user
/// is later told.
class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _search = TextEditingController();
  String _query = '';
  int _role = 0;
  int _status = 0;

  static const List<Role?> _roles = [
    null,
    Role.farmer,
    Role.vendor,
    Role.expert,
  ];
  static const List<AccountStatus?> _statuses = [
    null,
    AccountStatus.active,
    AccountStatus.pending,
    AccountStatus.suspended,
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final key = (
      query: _query,
      role: _roles[_role],
      status: _statuses[_status],
    );
    final async = ref.watch(adminUsersProvider(key));

    return AppScreen(
      title: l.navUsers,
      showBack: false,
      header: StaffTabHeader(
        title: l.navUsers,
        subtitle: l.adminUsersSubtitle,
        icon: Icons.people_alt_rounded,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(adminUsersProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              labelText: l.adminUserSearch,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: Space.sm),
          OpsFilters(
            labels: [
              l.filterAll,
              l.roleFarmer,
              l.roleVendor,
              l.roleExpert,
            ],
            index: _role,
            onChanged: (i) => setState(() => _role = i),
          ),
          const SizedBox(height: Space.xs),
          OpsFilters(
            labels: [
              l.filterAll,
              l.accountStatusActive,
              l.accountStatusPending,
              l.accountStatusSuspended,
            ],
            index: _status,
            onChanged: (i) => setState(() => _status = i),
          ),
          const SizedBox(height: Space.md),
          async.when(
            loading: () => const LoadingState(rows: 4),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(adminUsersProvider(key)),
            ),
            data: (users) {
              if (users.isEmpty) {
                return EmptyState(
                  icon: Icons.people_rounded,
                  title: l.adminUserEmpty,
                  body: l.adminUserEmptyBody,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final user in users)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: _UserCard(user: user),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _UserCard extends ConsumerStatefulWidget {
  const _UserCard({required this.user});

  final PlatformUser user;

  @override
  ConsumerState<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends ConsumerState<_UserCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final user = widget.user;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Space.xs,
            runSpacing: Space.xxs,
            children: [
              Text(user.name, style: context.texts.titleSmall),
              OpsPill(
                label: l.accountStatus(user.status),
                tone: switch (user.status) {
                  AccountStatus.active => OpsTone.success,
                  AccountStatus.pending => OpsTone.warning,
                  AccountStatus.suspended ||
                  AccountStatus.removed =>
                    OpsTone.danger,
                },
              ),
            ],
          ),
          const SizedBox(height: Space.xxs),
          Text(
            '${user.mobile} · ${user.role.label(l)}',
            style: context.texts.bodySmall,
          ),
          Text(
            '${user.district} · ${f.shortDate(user.joinedAt)}',
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
          if (user.reason != null) ...[
            const SizedBox(height: Space.xxs),
            Text(
              user.reason!,
              style: context.texts.bodySmall?.copyWith(color: p.error),
            ),
          ],
          const SizedBox(height: Space.xs),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              if (user.status != AccountStatus.active)
                AppButton(
                  label: l.adminActivate,
                  tone: AppButtonTone.secondary,
                  expand: false,
                  isLoading: _busy,
                  onPressed: () =>
                      _set(AccountStatus.active),
                ),
              if (user.status == AccountStatus.active)
                AppButton(
                  label: l.adminSuspend,
                  tone: AppButtonTone.danger,
                  expand: false,
                  onPressed: _suspend,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _suspend() async {
    final l = AppL10n.of(context);
    final reason = await askStaffReason(
      context,
      title: l.adminSuspendTitle,
      hint: l.adminReasonHint,
      actionLabel: l.adminSuspend,
    );
    if (reason == null) return;
    await _set(AccountStatus.suspended, reason: reason);
  }

  Future<void> _set(AccountStatus status, {String? reason}) async {
    final l = AppL10n.of(context);
    setState(() => _busy = true);
    try {
      await ref
          .read(adminRepositoryProvider)
          .setUserStatus(widget.user.id, status, reason: reason);
      ref.invalidate(adminUsersProvider);
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.adminUserUpdated)),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }
}
