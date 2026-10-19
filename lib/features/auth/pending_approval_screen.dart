import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/states.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';

/// Where a vendor or expert waits after registering.
///
/// This is a real screen rather than a blocked state because the SRS's UC-12
/// alternate flow is "the account stays unverified until the admin approves it",
/// and a user who has just handed over their trade licence needs to see that it
/// went somewhere.
class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(body: LoadingState(rows: 2));
    }

    final isVendor = user.role == Role.vendor;
    final isExpert = user.role == Role.expert;
    final shop = user.vendor?.shopName;
    final specialization = user.expert?.specialization;
    final roleLabel = isVendor
        ? l.roleVendor
        : isExpert
            ? l.roleExpert
            : l.roleFarmer;
    final roleIcon = isVendor
        ? Icons.storefront_rounded
        : isExpert
            ? Icons.school_rounded
            : Icons.agriculture_rounded;

    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(Space.md),
          children: [
            const SizedBox(height: Space.xl),
            Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.harvestContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: p.onHarvestContainer,
                  width: p.borderWidth,
                ),
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                size: 48,
                color: p.onHarvestContainer,
              ),
            ),
            const SizedBox(height: Space.md),
            Text(
              l.pendingTitle,
              textAlign: TextAlign.center,
              style: context.texts.titleLarge,
            ),
            const SizedBox(height: Space.xs),
            Text(
              l.pendingBody,
              textAlign: TextAlign.center,
              style: context.texts.bodyMedium?.copyWith(
                color: p.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: Space.md),
            AppCard(
              tint: p.harvestContainer,
              child: Row(
                children: [
                  Icon(Icons.timer_rounded, color: p.onHarvestContainer),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(
                      l.pendingPromise,
                      style: context.texts.bodySmall?.copyWith(
                        color: p.onHarvestContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.md),
            AppCard(
              child: Column(
                children: [
                  _Step(
                    icon: Icons.check_circle_rounded,
                    title: l.pendingStepSubmitted,
                    done: true,
                  ),
                  _Step(
                    icon: Icons.manage_search_rounded,
                    title: l.pendingStepReview,
                    body: l.pendingStepReviewBody,
                    done: false,
                  ),
                  _Step(
                    icon: Icons.verified_rounded,
                    title: l.pendingStepLive,
                    done: false,
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.lg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListRow(
                    title: user.name,
                    subtitle: user.mobile,
                    leading: CircleAvatar(
                      backgroundColor: p.primaryContainer,
                      child: Text(
                        user.initials,
                        style: context.texts.labelLarge
                            ?.copyWith(color: p.onPrimaryContainer),
                      ),
                    ),
                  ),
                  const Divider(),
                  ListRow(
                    title: roleLabel,
                    subtitle: isVendor
                        ? shop
                        : isExpert
                            ? specialization
                            : user.district,
                    leading: Icon(roleIcon, color: p.onSurfaceMuted),
                    trailing: const VerifiedBadge(verified: false),
                  ),
                  const Divider(),
                  ListRow(
                    title: l.registerDistrictLabel,
                    subtitle: user.district,
                    leading: Icon(Icons.place_outlined, color: p.onSurfaceMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.lg),
            AppButton(
              label: l.pendingCheckStatus,
              tone: AppButtonTone.secondary,
              icon: Icons.refresh_rounded,
              // Re-reads the session, which is how the status change would arrive
              // once a real backend exists.
              onPressed: () => ref.invalidate(sessionProvider),
            ),
            const SizedBox(height: Space.xs),
            AppButton(
              label: l.profileLogout,
              tone: AppButtonTone.quiet,
              onPressed: () => ref.read(sessionProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}

/// One line of the approval timeline. The first two steps are always reached
/// once the screen is visible; the last one is the promise, not a claim.
class _Step extends StatelessWidget {
  const _Step({
    required this.icon,
    required this.title,
    required this.done,
    this.body,
    this.last = false,
  });

  final IconData icon;
  final String title;
  final String? body;
  final bool done;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = done ? p.success : p.onSurfaceMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, size: 20, color: color),
            if (!last)
              Container(
                width: 2,
                height: body == null ? 18 : 30,
                color: p.outline,
              ),
          ],
        ),
        const SizedBox(width: Space.sm),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 1, bottom: last ? 0 : Space.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.texts.labelLarge?.copyWith(
                    color: done ? p.onSurface : p.onSurfaceMuted,
                    fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                if (body != null)
                  Text(
                    body!,
                    style: context.texts.bodySmall
                        ?.copyWith(color: p.onSurfaceMuted),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
