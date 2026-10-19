import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/growth.dart';

/// One or two initials for an avatar, safe for Bangla.
///
/// Two Bangla graphemes can join into a different-looking word (`সে` + `বে`
/// reads as `সেবে`), so a Bangla name gets one grapheme only. English keeps the
/// familiar two-letter mark.
String staffInitials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  final first = parts.first.characters.first;
  if (parts.length == 1) return first;
  final last = parts.last.characters.first;
  final bangla = RegExp(r'[\u0980-\u09FF]');
  return bangla.hasMatch(first) ? first : first + last;
}

/// The visual language shared by the vendor, expert and admin panels.
///
/// The farmer side was designed first and carries the app's warmth; the staff
/// panels used to be flat lists that all looked the same. Everything here is
/// built from the same palette and the same 8pt grid, but with a painted header,
/// coloured metric tiles and a chart — enough surface to make a console feel
/// like a place to work rather than a settings dump.

/// The large header that opens each staff console home.
///
/// A gradient of the palette's own greens rather than a new colour: high
/// contrast mode swaps the palette and the header follows, so the white ink is
/// still guaranteed to pass at both ends.
class StaffHero extends StatelessWidget {
  const StaffHero({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.initials,
    required this.icon,
    this.actions = const [],
    this.footer,
    this.onAvatarTap,
  });

  /// Small caps line above the title, e.g. the role name.
  final String eyebrow;
  final String title;
  final String subtitle;
  final String initials;
  final IconData icon;
  final List<Widget> actions;

  /// Extra content pinned to the bottom of the panel, e.g. a strip of stats.
  final Widget? footer;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ink = p.onPrimary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radii.band),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.primaryDark, p.primary],
          ),
        ),
        child: Stack(
          children: [
            // Two soft rings instead of an illustration: they read as a printed
            // panel, cost nothing to draw and never fail to load.
            Positioned(
              right: -34,
              top: -54,
              child: _Ring(size: 190, opacity: 0.10, color: ink),
            ),
            Positioned(
              right: 42,
              bottom: -74,
              child: _Ring(size: 150, opacity: 0.07, color: p.harvest),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Space.md,
                  Space.sm,
                  Space.xs,
                  Space.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: onAvatarTap,
                          borderRadius: Radii.chipAll,
                          child: Container(
                            width: Sizes.avatar,
                            height: Sizes.avatar,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: ink.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: ink.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              initials,
                              style: context.texts.labelLarge?.copyWith(
                                color: ink,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Space.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(icon, size: 14, color: ink),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      eyebrow,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: context.texts.labelSmall?.copyWith(
                                        color: ink.withValues(alpha: 0.86),
                                        letterSpacing: 0.4,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.texts.titleMedium?.copyWith(
                                  color: ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        for (final action in actions)
                          IconTheme.merge(
                            data: IconThemeData(color: ink),
                            child: action,
                          ),
                      ],
                    ),
                    const SizedBox(height: Space.md),
                    Text(
                      subtitle,
                      style: context.texts.bodySmall?.copyWith(
                        color: ink.withValues(alpha: 0.82),
                      ),
                    ),
                    if (footer != null) ...[
                      const SizedBox(height: Space.md),
                      footer!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact header for a tab that is not the home screen. Replaces the plain
/// AppBar so every staff tab carries the same painted edge.
class StaffTabHeader extends StatelessWidget {
  const StaffTabHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actions = const [],
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Widget> actions;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ink = p.onPrimary;
    final canPop = Navigator.of(context).canPop();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radii.tile),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.primaryDark, p.primary],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Space.xs,
              Space.xs,
              Space.xs,
              Space.sm,
            ),
            child: Row(
              children: [
                if (showBack && canPop)
                  IconButton(
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back_rounded, color: ink),
                  )
                else
                  const SizedBox(width: Space.xs),
                if (icon != null) ...[
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ink.withValues(alpha: 0.14),
                      borderRadius: Radii.fieldAll,
                    ),
                    child: Icon(icon, size: 20, color: ink),
                  ),
                  const SizedBox(width: Space.sm),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.titleMedium?.copyWith(
                          color: ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.texts.bodySmall?.copyWith(
                            color: ink.withValues(alpha: 0.8),
                          ),
                        ),
                    ],
                  ),
                ),
                for (final action in actions)
                  IconTheme.merge(
                    data: IconThemeData(color: ink),
                    child: action,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.size,
    required this.opacity,
    required this.color,
  });

  final double size;
  final double opacity;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: 22,
          ),
        ),
      ),
    );
  }
}

/// A number with its label on a coloured plate. Four of these are the first
/// thing a console shows, so they carry an icon rather than a bare figure.
class StaffKpi extends StatelessWidget {
  const StaffKpi({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.tone,
    this.trend,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;

  /// Overrides the plate colour; defaults to the green container.
  final Color? tone;

  /// A short line under the number, e.g. "+12%". Omitted when there is nothing
  /// truthful to say.
  final String? trend;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final plate = tone ?? p.primaryContainer;
    final ink = tone == null ? p.onPrimaryContainer : p.onSurface;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: plate,
                  borderRadius: Radii.fieldAll,
                ),
                child: Icon(icon, size: 17, color: ink),
              ),
              const Spacer(),
              if (trend != null)
                Flexible(
                  child: Text(
                    trend!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: context.texts.labelSmall?.copyWith(
                      color: p.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

/// A row of two [StaffKpi]s with the design's gap, so every dashboard aligns.
class StaffKpiRow extends StatelessWidget {
  const StaffKpiRow({super.key, required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: Space.xs),
        Expanded(child: right),
      ],
    );
  }
}

/// A labelled section heading with the accent icon the staff panels use.
class StaffSectionTitle extends StatelessWidget {
  const StaffSectionTitle({
    super.key,
    required this.title,
    required this.icon,
    this.actionLabel,
    this.onAction,
    this.count,
  });

  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.xs),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.primaryContainer,
              borderRadius: Radii.fieldAll,
            ),
            child: Icon(icon, size: 16, color: p.onPrimaryContainer),
          ),
          const SizedBox(width: Space.xs),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.texts.titleSmall,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            StaffCountBadge(count: count!),
          ],
          const Spacer(),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: Space.xs),
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

/// Small round count, used on section headings and nav destinations.
class StaffCountBadge extends StatelessWidget {
  const StaffCountBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
      decoration: BoxDecoration(
        color: p.harvestContainer,
        borderRadius: Radii.chipAll,
      ),
      child: Text(
        '$count',
        style: context.texts.labelSmall?.copyWith(
          color: p.onHarvestContainer,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// A day-by-day bar chart. Values are fractions of the tallest bar, so money,
/// orders and visitors can all use it without a second widget.
class StaffChart extends StatelessWidget {
  const StaffChart({
    super.key,
    required this.points,
    required this.labels,
    this.height = 96,
    this.accent,
    this.valueLabel,
  });

  final List<TrendPoint> points;

  /// Day labels, same length as [points].
  final List<String> labels;
  final double height;
  final Color? accent;

  /// Optional formatter for the "selected" bar's value.
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final f = AppFormat.of(context);
    final color = accent ?? p.primary;
    final maxValue = points.fold<double>(
      1,
      (max, point) => math.max(max, point.value),
    );
    final last = points.isEmpty ? -1 : points.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (valueLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.xs),
            child: Text(
              valueLabel!,
              style: context.texts.titleSmall,
            ),
          ),
        SizedBox(
          // Extra room beyond the bar height so the value label above the tallest
          // bar can never push the row past its box.
          height: height + 10,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < points.length; i++) ...[
                if (i > 0) const SizedBox(width: Space.xxs),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _short(f, points[i].value),
                        maxLines: 1,
                        style: context.texts.labelSmall?.copyWith(
                          color: i == last ? color : p.onSurfaceMuted,
                          fontWeight:
                              i == last ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        child: Container(
                          height: math.max(
                            6,
                            (height - 34) * (points[i].value / maxValue),
                          ),
                          color: i == last
                              ? color
                              : color.withValues(alpha: 0.26),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.xxs),
        Row(
          children: [
            for (var i = 0; i < labels.length; i++) ...[
              if (i > 0) const SizedBox(width: Space.xxs),
              Expanded(
                child: Text(
                  labels[i],
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.labelSmall
                      ?.copyWith(color: p.onSurfaceMuted),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Compact value label for the bar. Formatted through [AppFormat] so a
  /// Bangla screen reads `৯২ হাজার`, not `92.0k` in Latin digits.
  String _short(AppFormat f, double value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      final whole = thousands.truncateToDouble() == thousands;
      return '${f.number(thousands, decimals: whole ? 0 : 1)}k';
    }
    return f.number(value.round());
  }
}

/// One tappable action on a console home. Badge is used for a real count (a
/// queue), never as decoration.
class StaffActionTile extends StatelessWidget {
  const StaffActionTile({
    super.key,
    required this.icon,
    required this.label,
    this.badge,
    this.onTap,
    this.tone,
  });

  final IconData icon;
  final String label;
  final int? badge;
  final VoidCallback? onTap;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final plate = tone ?? p.primaryContainer;
    final ink = tone == null ? p.onPrimaryContainer : p.onSurface;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(Space.sm),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: plate,
              borderRadius: Radii.fieldAll,
            ),
            child: Icon(icon, size: 20, color: ink),
          ),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.texts.labelLarge,
            ),
          ),
          if (badge != null && badge! > 0) StaffCountBadge(count: badge!),
        ],
      ),
    );
  }
}

/// Two-column grid of [StaffActionTile]s.
class StaffActionGrid extends StatelessWidget {
  const StaffActionGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) const SizedBox(height: Space.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: children[i]),
              if (i + 1 < children.length) ...[
                const SizedBox(width: Space.xs),
                Expanded(child: children[i + 1]),
              ] else
                const Spacer(),
            ],
          ),
        ],
      ],
    );
  }
}

/// Initials avatar with an optional verified dot. Staff lists are dense, so
/// this is 40dp rather than a full card.
class StaffAvatar extends StatelessWidget {
  const StaffAvatar({
    super.key,
    this.initials = '',
    this.size = 40,
    this.verified = false,
    this.icon,
  });

  final String initials;
  final double size;
  final bool verified;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.primaryContainer,
            shape: BoxShape.circle,
            border: Border.all(color: p.outline, width: p.borderWidth),
          ),
          child: icon == null
              ? Text(
                  initials,
                  style: context.texts.labelLarge?.copyWith(
                    color: p.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                  ),
                )
              : Icon(icon, size: size * 0.5, color: p.onPrimaryContainer),
        ),
        if (verified)
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 16,
              height: 16,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.success,
                shape: BoxShape.circle,
                border: Border.all(color: p.surface, width: 2),
              ),
              child: Icon(Icons.check_rounded, size: 10, color: p.onPrimary),
            ),
          ),
      ],
    );
  }
}

/// Five stars plus the numeric average.
class StaffRating extends StatelessWidget {
  const StaffRating({
    super.key,
    required this.rating,
    this.count,
    this.size = 15,
  });

  final double rating;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            i <= rating.round()
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            size: size,
            color: p.harvest,
          ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: context.texts.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        if (count != null)
          Text(
            ' (${AppFormat.of(context).number(count!)})',
            style: context.texts.labelSmall?.copyWith(color: p.onSurfaceMuted),
          ),
      ],
    );
  }
}

/// A tinted notice with an icon, used for the verification gate, a failed
/// source, or a pending subscription. [tone] is the surface behind the text.
class StaffNotice extends StatelessWidget {
  const StaffNotice({
    super.key,
    required this.icon,
    required this.title,
    this.body,
    this.tone,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Color? tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final plate = tone ?? p.primaryContainer;
    final ink = tone == null ? p.onPrimaryContainer : p.onSurface;

    return Container(
      padding: const EdgeInsets.all(Space.sm),
      decoration: BoxDecoration(
        color: plate,
        borderRadius: Radii.cardAll,
        border: Border.all(color: ink.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: ink),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.texts.titleSmall?.copyWith(color: ink),
                ),
                if (body != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      body!,
                      style: context.texts.bodySmall
                          ?.copyWith(color: ink.withValues(alpha: 0.86)),
                    ),
                  ),
                if (action != null)
                  Padding(
                    padding: const EdgeInsets.only(top: Space.xs),
                    child: action,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Label/value line for detail sheets. The value wraps rather than pushing the
/// label off a 320dp phone.
class StaffInfoRow extends StatelessWidget {
  const StaffInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: p.onSurfaceMuted),
          const SizedBox(width: Space.xs),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
            ),
          ),
          const SizedBox(width: Space.xs),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: context.texts.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A labelled progress bar. Used for stock health and subscription targets.
class StaffProgress extends StatelessWidget {
  const StaffProgress({
    super.key,
    required this.label,
    required this.value,
    required this.ratio,
    this.trailing,
  });

  final String label;
  final String value;
  final double ratio;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final clamped = ratio.clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall,
                ),
              ),
              const SizedBox(width: Space.xs),
              Text(
                value,
                style: context.texts.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (trailing != null)
                Text(
                  ' · $trailing',
                  style: context.texts.labelSmall
                      ?.copyWith(color: p.onSurfaceMuted),
                ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: Radii.chipAll,
            child: LinearProgressIndicator(
              value: clamped,
              minHeight: 7,
              backgroundColor: p.surfaceSunken,
              color: clamped > 0.6 ? p.primary : p.harvest,
            ),
          ),
        ],
      ),
    );
  }
}

/// A call-to-action line used at the bottom of a dashboard card: one icon, one
/// label, a chevron. Cheaper than a full button when the whole row is tappable.
class StaffLinkRow extends StatelessWidget {
  const StaffLinkRow({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ink = color ?? p.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: Radii.fieldAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xs),
        child: Row(
          children: [
            Icon(icon, size: 18, color: ink),
            const SizedBox(width: Space.xs),
            Expanded(
              child: Text(
                label,
                style: context.texts.labelLarge?.copyWith(color: ink),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: ink),
          ],
        ),
      ),
    );
  }
}
