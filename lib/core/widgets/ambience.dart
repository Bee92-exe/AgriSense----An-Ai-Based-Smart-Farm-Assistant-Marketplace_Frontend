import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

/// What a page's ambience should feel like.
///
/// One mood per surface, chosen from what the page is *about* — a bazaar page
/// drifts price tags, a history page drops leaves, a settings page breathes
/// rings. The motion is the page's own decoration, so no two screens look the
/// same when অ্যানিমেশন is on, and all of them are still the same app.
enum AmbienceMood { field, market, records, profile, weather, result, news, orders, auth }

/// The ambient layer that sits behind a page's content.
///
/// Cost and safety rules, in order of importance:
///  * Off by default. It paints nothing, and runs no ticker, unless the farmer
///    turned অ্যানিমেশন on.
///  * One [AnimationController] and one [CustomPainter] per page, wrapped in a
///    [RepaintBoundary], so a drifting motif never rebuilds a widget.
///  * Nothing painted under this layer carries meaning: it is texture at 4–8%
///    alpha, and it disappears entirely in sunlight mode and under reduce-motion.
///  * Element counts are fixed and small (max 18 shapes), so the cost is the
///    same on a flagship and on a low-end phone.
class AmbientBackdrop extends ConsumerStatefulWidget {
  const AmbientBackdrop({
    super.key,
    required this.mood,
    required this.child,
    this.scrollController,
  });

  final AmbienceMood mood;
  final Widget child;

  /// Optional page scroll controller, used for a slow parallax. The painter
  /// listens to it directly, so scrolling repaints one layer instead of
  /// rebuilding the page.
  final ScrollController? scrollController;

  @override
  ConsumerState<AmbientBackdrop> createState() => _AmbientBackdropState();
}

class _AmbientBackdropState extends ConsumerState<AmbientBackdrop>
    with SingleTickerProviderStateMixin {
  /// 18s for a full loop: long enough to feel like weather rather than a
  /// loading spinner, short enough that a farmer who turns the mode on sees
  /// something move within a second or two. The first version ran at 30s with
  /// 5px amplitudes, which is why it read as "nothing happened".
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncClock();
  }

  @override
  void didUpdateWidget(AmbientBackdrop old) {
    super.didUpdateWidget(old);
    _syncClock();
  }

  void _syncClock() {
    final wanted = ref.read(settingsProvider).animatedMode &&
        !MediaQuery.disableAnimationsOf(context) &&
        !context.isHighContrast &&
        TickerMode.valuesOf(context).enabled;

    if (wanted && !_clock.isAnimating) {
      _clock.repeat();
    } else if (!wanted && _clock.isAnimating) {
      _clock.stop();
      _clock.value = 0;
    }
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watched so toggling অ্যানিমেশন rebuilds this page's layer immediately
    // rather than on the next navigation. `listen` is what actually starts and
    // stops the ticker: a provider change rebuilds this State's `build`, it does
    // not create a new widget, so `didUpdateWidget` never runs for it.
    ref.listen<bool>(
      settingsProvider.select((s) => s.animatedMode),
      (_, _) => _syncClock(),
    );
    final animated = ref.watch(settingsProvider).animatedMode;
    final enabled = animated &&
        !MediaQuery.disableAnimationsOf(context) &&
        !context.isHighContrast &&
        TickerMode.valuesOf(context).enabled;

    return Stack(
      children: [
        if (enabled)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _AmbiencePainter(
                    mood: widget.mood,
                    clock: _clock,
                    scroll: widget.scrollController,
                    accent: context.palette.primary,
                    highlight: context.palette.harvest,
                  ),
                  isComplex: true,
                ),
              ),
            ),
          ),
        widget.child,
      ],
    );
  }
}

class _AmbiencePainter extends CustomPainter {
  _AmbiencePainter({
    required this.mood,
    required this.clock,
    required this.scroll,
    required this.accent,
    required this.highlight,
  }) : super(repaint: Listenable.merge([clock, scroll]));

  final AmbienceMood mood;
  final Animation<double> clock;
  final ScrollController? scroll;
  final Color accent;
  final Color highlight;

  /// Deterministic pseudo-random phase: the same page looks the same across
  /// rebuilds, which is what keeps this from reading as noise.
  static double _phase(int i, [int salt = 0]) =>
      ((i + 1) * 0.6180339887 + salt * 0.137) % 1;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    final parallax =
        (scroll?.hasClients ?? false ? scroll!.offset : 0.0) * 0.06;

    canvas.save();
    canvas.clipRect(Offset.zero & size);
    switch (mood) {
      case AmbienceMood.field:
        _arcs(canvas, size, t + parallax / 400);
      case AmbienceMood.market:
        _tags(canvas, size, t, parallax);
      case AmbienceMood.records:
        _leaves(canvas, size, t, parallax);
      case AmbienceMood.profile:
        _rings(canvas, size, t);
      case AmbienceMood.weather:
        _clouds(canvas, size, t, parallax);
      case AmbienceMood.result:
        _sweep(canvas, size, t);
      case AmbienceMood.news:
        _strips(canvas, size, t, parallax);
      case AmbienceMood.orders:
        _receiptLines(canvas, size, t, parallax);
      case AmbienceMood.auth:
        _rays(canvas, size, t);
    }
    canvas.restore();
  }

  /// The app's fish-scale alpona, drifting sideways. Shared with the Home hero.
  void _arcs(Canvas canvas, Size size, double t) {
    const unitW = 64.0;
    const unitH = 32.0;
    final rows = (size.height / unitH).ceil() + 1;
    final cols = (size.width / unitW).ceil() + 3;
    final offsetX = -(t % 1) * unitW;

    final stroke = Paint()
      ..color = accent.withValues(alpha: 0.075)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final dot = Paint()..color = highlight.withValues(alpha: 0.095);

    for (var row = 0; row < rows; row++) {
      final y = row * unitH;
      final xShift = row.isEven ? 0.0 : unitW / 2;
      for (var col = 0; col < cols; col++) {
        final x = col * unitW + xShift + offsetX;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(x, y + unitH), radius: unitW / 2),
          math.pi,
          math.pi,
          false,
          stroke,
        );
        canvas.drawCircle(Offset(x, y + 5), 2, dot);
      }
    }
  }

  /// Haat_Bazar: little price tags rising like dust above a market.
  void _tags(Canvas canvas, Size size, double t, double parallax) {
    for (var i = 0; i < 16; i++) {
      final x = _phase(i, 1) * size.width + math.sin((t + i) * 2 * math.pi) * 6;
      final y = ((_phase(i, 2) + t * 0.35 + parallax / 600) % 1) *
              (size.height + 60) -
          30;
      final w = 12.0 + _phase(i, 3) * 8;
      final h = w * 1.25;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(math.sin((t * 2 + i) * math.pi) * 0.4);
      final paint = Paint()
        ..color = (i.isEven ? accent : highlight).withValues(alpha: 0.10);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: h),
          const Radius.circular(3),
        ),
        paint,
      );
      canvas.drawCircle(
        Offset(0, -h / 2 + 3),
        1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.5),
      );
      canvas.restore();
    }
  }

  /// Itihas: the previous photos falling like leaves from a tree.
  void _leaves(Canvas canvas, Size size, double t, double parallax) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var i = 0; i < 12; i++) {
      final progress = (_phase(i, 2) + t * 0.5 + parallax / 500) % 1;
      final y = progress * (size.height + 80) - 40;
      final x = _phase(i, 1) * size.width +
          math.sin((progress * 2 + i) * math.pi) * 24;
      final r = 5.0 + _phase(i, 3) * 5;

      paint.color = (i.isEven ? accent : highlight)
          .withValues(alpha: 0.08 + 0.06 * (1 - progress));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((progress + i) * math.pi);
      final leaf = Path()
        ..moveTo(0, -r)
        ..quadraticBezierTo(r, 0, 0, r)
        ..quadraticBezierTo(-r, 0, 0, -r);
      canvas.drawPath(leaf, paint);
      canvas.restore();
    }
  }

  /// Profile: slow rings breathing out of the top-right corner.
  void _rings(Canvas canvas, Size size, double t) {
    final centre = Offset(size.width * 0.92, size.height * 0.08);
    final maxR = math.max(size.width, size.height) * 0.9;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (var i = 0; i < 5; i++) {
      final progress = ((t * 0.5 + i / 5) % 1);
      paint.color = accent.withValues(alpha: 0.12 * (1 - progress));
      canvas.drawCircle(centre, 24 + progress * maxR, paint);
    }
  }

  /// Weather: cloud puffs drifting across, under a slowly turning sun.
  void _clouds(Canvas canvas, Size size, double t, double parallax) {
    final sun = Offset(size.width * 0.82, size.height * 0.10);
    final ray = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = highlight.withValues(alpha: 0.11);
    for (var i = 0; i < 8; i++) {
      final a = (i / 8) * math.pi * 2 + t * math.pi * 2;
      canvas.drawLine(
        sun + Offset(math.cos(a), math.sin(a)) * 26,
        sun + Offset(math.cos(a), math.sin(a)) * (36 + 6 * math.sin(t * 6)),
        ray,
      );
    }

    for (var i = 0; i < 4; i++) {
      final row = _phase(i, 3) * size.height * 0.7 + 40;
      final x = ((_phase(i, 1) + t * (0.12 + i * 0.04) + parallax / 900) % 1.4 -
              0.2) *
          size.width;
      final scale = 0.8 + _phase(i, 2) * 0.9;
      final paint = Paint()
        ..color = (i.isEven ? accent : highlight).withValues(alpha: 0.05);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, row),
          width: 110 * scale,
          height: 26 * scale,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + 26 * scale, row - 12 * scale),
          width: 56 * scale,
          height: 30 * scale,
        ),
        paint,
      );
    }
  }

  /// Result: a scanner band passing down the page, once per loop.
  void _sweep(Canvas canvas, Size size, double t) {
    final y = t * (size.height + 160) - 80;
    final rect = Rect.fromLTWH(0, y, size.width, 120);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accent.withValues(alpha: 0),
            accent.withValues(alpha: 0.09),
            accent.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  /// Krishi Barta: columns of type drifting up like a printing press.
  void _strips(Canvas canvas, Size size, double t, double parallax) {
    final paint = Paint()
      ..color = accent.withValues(alpha: 0.075)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var col = 0; col < 5; col++) {
      final x = (col + 0.5) * size.width / 5;
      for (var i = 0; i < 6; i++) {
        final progress = ((_phase(col * 6 + i, 2) + t * 0.4 +
                    parallax / 700) %
                1);
        final y = progress * (size.height + 60) - 30;
        final w = 18.0 + _phase(col * 6 + i, 3) * 22;
        canvas.drawLine(Offset(x - w / 2, y), Offset(x + w / 2, y), paint);
      }
    }
  }

  /// Orders: rubric lines and tick marks floating up a ledger.
  void _receiptLines(Canvas canvas, Size size, double t, double parallax) {
    final line = Paint()
      ..color = accent.withValues(alpha: 0.075)
      ..strokeWidth = 1.4;
    final tick = Paint()..color = highlight.withValues(alpha: 0.11);

    for (var i = 0; i < 12; i++) {
      final progress = ((_phase(i, 2) + t * 0.4 + parallax / 700) % 1);
      final y = progress * (size.height + 40) - 20;
      final left = size.width * (0.12 + _phase(i, 1) * 0.2);
      final right = left + 40 + _phase(i, 3) * 60;
      canvas.drawLine(Offset(left, y), Offset(right, y), line);
      if (i.isEven) {
        canvas.drawCircle(Offset(left - 8, y), 2.2, tick);
      }
    }
  }

  /// Login: dawn rays widening across the top of the screen.
  void _rays(Canvas canvas, Size size, double t) {
    final origin = Offset(size.width * 0.5, -size.height * 0.25);
    final paint = Paint()
      ..color = highlight.withValues(alpha: 0.075)
      ..strokeWidth = 26
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 6; i++) {
      final a = math.pi * (0.18 + i * 0.13) + math.sin(t * math.pi * 2) * 0.02;
      canvas.drawLine(
        origin,
        origin + Offset(math.cos(a), math.sin(a)) * size.height * 1.2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_AmbiencePainter old) =>
      old.mood != mood || old.accent != accent || old.highlight != highlight;
}

/// Fades and lifts a page's content into place once, when অ্যানিমেশন is on.
///
/// It animates opacity and translation only, so it never changes a layout it
/// could break, and it is skipped completely — no ticker, no keyframe — in
/// sunlight mode, under reduce-motion, or with the mode off.
class PageReveal extends ConsumerStatefulWidget {
  const PageReveal({super.key, required this.child, this.duration});

  final Widget child;
  final Duration? duration;

  @override
  ConsumerState<PageReveal> createState() => _PageRevealState();
}

class _PageRevealState extends ConsumerState<PageReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration ?? const Duration(milliseconds: 420),
  );

  bool _decided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_decided) return;
    _decided = true;
    final play = ref.read(settingsProvider).animatedMode &&
        !MediaQuery.disableAnimationsOf(context);
    if (play) {
      _c.forward();
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.015),
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

/// A sheen that crosses a surface every few seconds, used on the Home hero's
/// primary action so the animated mode has one bright, obvious cue rather than
/// only background texture.
class AnimatedSheen extends ConsumerStatefulWidget {
  const AnimatedSheen({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  ConsumerState<AnimatedSheen> createState() => _AnimatedSheenState();
}

class _AnimatedSheenState extends ConsumerState<AnimatedSheen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(AnimatedSheen old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final wanted = widget.enabled &&
        ref.read(settingsProvider).animatedMode &&
        !MediaQuery.disableAnimationsOf(context) &&
        !context.isHighContrast &&
        TickerMode.valuesOf(context).enabled;
    if (wanted && !_c.isAnimating) {
      _c.repeat();
    } else if (!wanted && _c.isAnimating) {
      _c.stop();
      _c.value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(
      settingsProvider.select((s) => s.animatedMode),
      (_, _) => _sync(),
    );
    return Stack(
      children: [
        widget.child,
        if (widget.enabled)
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    if (!_c.isAnimating) return const SizedBox.shrink();
                    return FractionallySizedBox(
                      widthFactor: 0.35,
                      alignment: Alignment(-1 + _c.value * 4, 0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.22),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
