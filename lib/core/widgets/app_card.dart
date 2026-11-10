import 'package:flutter/material.dart';

import '../theme/app_metrics.dart';
import '../theme/app_theme.dart';

/// The one surface every panel in the app is built on.
///
/// Elevation is 0 and the boundary is a border: shadows are unreliable in
/// sunlight, and high-contrast mode replaces the 1dp hairline with a 2dp black
/// rule from the palette rather than a different widget.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(Space.md),
    this.onTap,
    this.tint,
    this.radius = Radii.cardAll,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Overrides the surface colour — used by the action tiles and by accent
  /// panels such as the urgent-news banner.
  final Color? tint;

  final BorderRadius radius;
  final String? semanticLabel;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = widget.radius;

    // The surface is a [Material], not a painted box: ListTile, InkWell and
    // anything else that inks on the nearest Material must find one *above* the
    // background colour. With only a coloured DecoratedBox in between, the
    // splash is invisible and Flutter asserts in debug builds.
    Widget child = Padding(padding: widget.padding, child: widget.child);
    if (widget.onTap != null) {
      child = InkWell(
        onTap: widget.onTap,
        borderRadius: radius,
        onHighlightChanged: (v) => setState(() => _pressed = v),
        child: child,
      );
    }

    final content = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: p.outline, width: p.borderWidth),
        boxShadow: p.useShadow
            ? const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: widget.tint ?? p.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: child,
      ),
    );

    // A 1.5% press scale. Small enough that it never disturbs a reading eye,
    // large enough that the surface answers a thumb — and it collapses to no
    // motion under reduce-motion because it goes through [Motion.duration].
    final body = widget.onTap == null
        ? content
        : AnimatedScale(
            scale: _pressed ? 0.985 : 1,
            duration: Motion.duration(context, Motion.fast),
            curve: Curves.easeOut,
            child: content,
          );

    if (widget.onTap == null && widget.semanticLabel == null) return body;

    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      container: true,
      child: body,
    );
  }
}

/// Section heading with an optional "see all" action. Kept separate from
/// [AppCard] because it sits in the page flow, not on a surface.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.texts;
    final p = context.palette;

    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: Sizes.iconInline, color: p.primary),
          const SizedBox(width: Space.xs),
        ],
        Expanded(child: Text(title, style: t.titleMedium)),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

/// A single row inside a card: leading visual, title, supporting line, trailing.
///
/// Rows are forced to at least [Sizes.minTapTarget] tall so a list of these
/// still satisfies the tap-target floor without every screen re-checking it.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.semanticLabel,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.texts;
    final p = context.palette;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Sizes.minTapTarget),
      child: Semantics(
        button: onTap != null,
        label: semanticLabel,
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.cardAll,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // `trailing` is usually a status pill. Pills are laid out at their
              // intrinsic width inside a Row, so a long Bangla status would push
              // the row past the card; cap it and let it ellipsize instead.
              final trailingMax = constraints.maxWidth * 0.42;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.xs),
                child: Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: Space.sm),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title, style: t.titleSmall),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: t.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: Space.xs),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: trailingMax),
                        child: trailing!,
                      ),
                    ] else if (onTap != null)
                      Icon(
                        Icons.chevron_right_rounded,
                        color: p.onSurfaceMuted,
                        size: Sizes.iconInline,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
