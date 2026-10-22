import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/ambience.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/states.dart';
import '../../data/models/crop.dart';
import '../../data/models/enums.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shell/farmer_shell.dart';

final calendarProvider = FutureProvider.family<CropCalendar, CropType>(
  (ref, crop) => ref.watch(cropRepositoryProvider).calendar(crop),
);

/// Seasonal calendar (FR-15).
///
/// Twelve months in one strip, because the question a farmer is actually asking
/// is "is there anything to do this month?" — a list of windows with dates makes
/// them work that out. Each month carries its planting/harvest marks *and* its
/// name, so the month is never identified by colour alone, and the windows are
/// repeated as rows below for anyone who needs the note text.
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key, required this.crop});

  final String crop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final cropType = CropType.fromWire(crop) ?? CropType.rice;
    final async = ref.watch(calendarProvider(cropType));

    return AppScreen(
      title: '${l.calendarTitle} · ${cropType.label(l)}',
      ambience: AmbienceMood.field,
      bottomNav: const FarmerNav(current: FarmerTab.home),
      fab: const FarmerMicFab(),
      child: async.when(
        loading: () => const LoadingState(rows: 3),
        error: (_, _) => ErrorState(
          onRetry: () => ref.invalidate(calendarProvider(cropType)),
        ),
        data: (calendar) => calendar.windows.isEmpty
            ? EmptyState(
                icon: Icons.calendar_month_rounded,
                title: l.calendarEmpty,
                body: l.calendarLegend,
                actionLabel: l.adviceTitle,
                onAction: () => context.go(Routes.cropAdvice),
              )
            : _Body(calendar: calendar),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.calendar});

  final CropCalendar calendar;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.calendarLegend, style: context.texts.bodySmall),
        const SizedBox(height: Space.sm),
        // One strip, left to right, the way a year reads. Wrapped rather than
        // horizontally scrolled: 12 months must be visible at once for the
        // "which months have work" question to be answerable at a glance.
        Wrap(
          spacing: Space.xxs,
          runSpacing: Space.xxs,
          children: [
            for (var month = 1; month <= 12; month++)
              _MonthCell(
                month: month,
                planting: calendar.windows.any(
                  (w) =>
                      w.activity == CropActivity.planting && w.covers(month),
                ),
                harvest: calendar.windows.any(
                  (w) => w.activity == CropActivity.harvest && w.covers(month),
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.sm),
        // A Wrap, not a Row: at 320dp and 1.3x Bangla the two labels do not fit
        // on one line, and a clipped legend is worse than a second row.
        Wrap(
          spacing: Space.md,
          runSpacing: Space.xxs,
          children: [
            _Legend(
              colour: p.primary,
              icon: Icons.grass_rounded,
              label: l.calendarPlanting,
            ),
            _Legend(
              colour: p.harvest,
              icon: Icons.agriculture_rounded,
              label: l.calendarHarvest,
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        for (final window in calendar.windows) ...[
          _WindowRow(window: window, crop: calendar.crop),
          const SizedBox(height: Space.xs),
        ],
      ],
    );
  }
}

/// One month on the strip. A month with both activities shows both marks, so no
/// information is lost when the two overlap.
class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.month,
    required this.planting,
    required this.harvest,
  });

  final int month;
  final bool planting;
  final bool harvest;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final f = AppFormat.of(context);
    final active = planting || harvest;

    return Semantics(
      label: [
        l.calendarMonth(f.number(month)),
        if (planting) l.calendarPlanting,
        if (harvest) l.calendarHarvest,
      ].join(', '),
      child: Container(
        width: 68,
        padding: const EdgeInsets.symmetric(vertical: Space.xs),
        decoration: BoxDecoration(
          color: active ? p.primaryContainer : p.surface,
          borderRadius: Radii.chipAll,
          border: Border.all(
            color: active ? p.primary : p.outline,
            width: p.borderWidth,
          ),
        ),
        child: Column(
          children: [
            Text(
              f.monthName(month),
              style: context.texts.labelSmall?.copyWith(
                color: active ? p.onPrimaryContainer : p.onSurface,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (planting)
                  Icon(Icons.grass_rounded, size: 16, color: p.primary),
                if (harvest)
                  Padding(
                    padding: EdgeInsets.only(left: planting ? 2 : 0),
                    child: Icon(
                      Icons.agriculture_rounded,
                      size: 16,
                      color: p.harvest,
                    ),
                  ),
                if (!active)
                  SizedBox(
                    height: 16,
                    child: Center(
                      child: Text('–', style: context.texts.labelSmall),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.colour,
    required this.icon,
    required this.label,
  });

  final Color colour;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colour),
          const SizedBox(width: 4),
          // Flexible, so a long label at 1.3x text wraps instead of pushing the
          // row past the edge of a 320dp screen.
          Flexible(
            child: Text(label, style: context.texts.bodySmall),
          ),
        ],
      );
}

class _WindowRow extends StatelessWidget {
  const _WindowRow({required this.window, required this.crop});

  final CropWindow window;
  final CropType crop;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final planting = window.activity == CropActivity.planting;

    return ListRow(
      leading: Icon(
        planting ? Icons.grass_rounded : Icons.agriculture_rounded,
        color: planting ? context.palette.primary : context.palette.harvest,
      ),
      title: planting ? l.calendarPlanting : l.calendarHarvest,
      subtitle: [
        '${f.monthName(window.startMonth)} – ${f.monthName(window.endMonth)}',
        if (window.noteBn != null) window.noteBn!,
      ].join(' · '),
      trailing: crop == CropType.rice
          ? null
          : IconButton(
              tooltip: l.adviceTitle,
              onPressed: () => context.go(Routes.cropAdvice),
              icon: const Icon(Icons.eco_rounded),
            ),
    );
  }
}
