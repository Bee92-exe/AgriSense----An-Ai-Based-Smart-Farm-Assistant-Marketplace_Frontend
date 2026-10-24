import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/states.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';
import 'staff_widgets.dart';

/// Profile and settings for the three staff roles.
///
/// The farmer's profile screen carries a farm size, crop preferences and the
/// farmer shell's own nav; none of that applies here, and reusing it would have
/// meant either dummy fields or a screen full of farmer-only sections. This is
/// the same information a staff account actually has — plus the two settings
/// that matter to them (language, sunlight mode).
class StaffProfileScreen extends ConsumerWidget {
  const StaffProfileScreen({super.key, this.showBack = false});

  /// True when the screen was pushed as a route (the admin's system tab opens
  /// it that way); false when it is a bottom tab of its own shell.
  final bool showBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(settingsProvider);

    if (user == null) {
      return AppScreen(
        title: l.profileTitle,
        showBack: showBack,
        child: const LoadingState(rows: 2),
      );
    }

    return AppScreen(
      title: l.profileTitle,
      showBack: showBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: p.primaryContainer,
                  child: Text(
                    user.initials,
                    style: context.texts.titleSmall
                        ?.copyWith(color: p.onPrimaryContainer),
                  ),
                ),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: context.texts.titleSmall),
                      Text(
                        user.role.label(l),
                        style: context.texts.bodySmall
                            ?.copyWith(color: p.onSurfaceMuted),
                      ),
                      Text(
                        '${user.mobile} · ${user.district ?? ''}',
                        style: context.texts.bodySmall
                            ?.copyWith(color: p.onSurfaceMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
          if (user.role == Role.vendor)
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.vendor?.shopName ?? '',
                          style: context.texts.titleSmall,
                        ),
                        const SizedBox(height: Space.xxs),
                        OpsPill(
                          label: l.vendorVerification(
                            user.vendor?.verificationStatus ?? 'pending',
                          ),
                          tone: (user.vendor?.isVerified ?? false)
                              ? OpsTone.success
                              : OpsTone.warning,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (user.role == Role.expert)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.expert?.specialization ?? '',
                    style: context.texts.titleSmall,
                  ),
                  if (user.expert?.certification != null)
                    Text(
                      user.expert!.certification!,
                      style:
                          context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
                    ),
                ],
              ),
            ),
          const SizedBox(height: Space.lg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.language_rounded, color: p.onSurfaceMuted),
                    const SizedBox(width: Space.sm),
                    Expanded(
                      child: Text(
                        l.profileLanguage,
                        style: context.texts.titleSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.xs),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'bn',
                      label: Text(l.languageBangla),
                    ),
                    ButtonSegment(
                      value: 'en',
                      label: Text(l.languageEnglish),
                    ),
                  ],
                  selected: {settings.language},
                  onSelectionChanged: (selection) => ref
                      .read(settingsProvider.notifier)
                      .setLanguage(selection.first),
                ),
                const SizedBox(height: Space.sm),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: settings.highContrast,
                  title: Text(l.profileContrast),
                  onChanged: (value) => ref
                      .read(settingsProvider.notifier)
                      .setHighContrast(value),
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.lg),
          AppButton(
            label: l.profileLogout,
            tone: AppButtonTone.quiet,
            icon: Icons.logout_rounded,
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: Text(l.profileLogout),
                  content: Text(l.profileLogoutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(l.actionCancel),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: Text(l.profileLogout),
                    ),
                  ],
                ),
              );
              if (confirmed != true) return;
              await ref.read(sessionProvider.notifier).logout();
            },
          ),
          const SizedBox(height: Space.sm),
          Center(
            child: Text(
              l.profileVersion('1.0.0'),
              style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
            ),
          ),
        ],
      ),
    );
  }
}
