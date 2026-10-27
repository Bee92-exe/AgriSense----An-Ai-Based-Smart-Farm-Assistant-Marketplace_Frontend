import 'dart:math' as math;

import 'package:agrisense/core/theme/app_colors.dart';
import 'package:agrisense/core/theme/sky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.1 relative luminance.
double _luminance(Color c) {
  double channel(double v) {
    return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(c.r) +
      0.7152 * channel(c.g) +
      0.0722 * channel(c.b);
}

double contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final hi = math.max(la, lb);
  final lo = math.min(la, lb);
  return (hi + 0.05) / (lo + 0.05);
}

/// Every foreground/background pair the app actually renders text on.
///
/// This list is the contract from docs/agrisense/frontend/docs/DESIGN_SYSTEM.md
/// ("all text >= 4.5:1", "target contrast >= 7:1" in high contrast). If a
/// palette value changes and breaks a pair, this test fails rather than the
/// failure reaching a farmer reading their phone in sunlight.
List<(String, Color, Color)> _pairs(AppPalette p) => [
      ('onSurface / background', p.onSurface, p.background),
      ('onSurface / surface', p.onSurface, p.surface),
      ('onSurfaceMuted / background', p.onSurfaceMuted, p.background),
      ('onSurfaceMuted / surface', p.onSurfaceMuted, p.surface),
      ('onSurfaceMuted / surfaceSunken', p.onSurfaceMuted, p.surfaceSunken),
      ('onPrimary / primary', p.onPrimary, p.primary),
      ('onPrimary / primaryDark', p.onPrimary, p.primaryDark),
      ('onPrimaryContainer / primaryContainer',
          p.onPrimaryContainer, p.primaryContainer),
      ('onHarvest / harvest', p.onHarvest, p.harvest),
      ('onHarvestContainer / harvestContainer',
          p.onHarvestContainer, p.harvestContainer),
      ('onAiAccent / aiAccent', p.onAiAccent, p.aiAccent),
      ('onAiContainer / aiContainer', p.onAiContainer, p.aiContainer),
      ('onInfo / info', p.onInfo, p.info),
      ('onError / error', p.onError, p.error),
      ('onErrorContainer / errorContainer',
          p.onErrorContainer, p.errorContainer),
      // Coloured *text* (links, outlined buttons, AI tags) on the page.
      ('primary / background', p.primary, p.background),
      ('primary / surface', p.primary, p.surface),
      ('aiAccent / background', p.aiAccent, p.background),
      ('aiAccent / surface', p.aiAccent, p.surface),
      ('error / background', p.error, p.background),
      ('error / surface', p.error, p.surface),
      ('warning / background', p.warning, p.background),
      ('warning / surface', p.warning, p.surface),
      ('info / surface', p.info, p.surface),
      ('success / surface', p.success, p.surface),
      // Severity chips carry icon + label on a tinted pill.
      ('severityLow on its tint', p.severityLow, p.severityLowContainer),
      ('severityMedium on its tint',
          p.severityMedium, p.severityMediumContainer),
      ('severityHigh on its tint',
          p.severityHigh, p.severityHighContainer),
      ('severityUrgent on its tint',
          p.severityUrgent, p.severityUrgentContainer),
    ];

void _expectAll(AppPalette app, String label, double target) {
  testWidgets('$label clears $target:1', (tester) async {
    final failures = <String>[];
    for (final (name, fg, bg) in _pairs(app)) {
      final ratio = contrast(fg, bg);
      if (ratio < target) {
        failures.add('$name = ${ratio.toStringAsFixed(2)}:1');
      }
    }
    expect(failures, isEmpty, reason: 'Below $target:1 —\n${failures.join('\n')}');
  });
}

void main() {
  _expectAll(AppPalette.light, 'light theme text', 4.5);
  _expectAll(AppPalette.highContrast, 'high-contrast theme text', 7.0);

  testWidgets('home action tints are legible', (tester) async {
    for (final palette in [AppPalette.light, AppPalette.highContrast]) {
      final target = palette.useShadow ? 4.5 : 7.0;
      for (var i = 0; i < palette.actionTints.length; i++) {
        final tint = palette.actionTints[i];
        expect(
          contrast(tint.foreground, tint.background),
          greaterThanOrEqualTo(target),
          reason: 'action tint $i is below $target:1',
        );
      }
    }
  });

  testWidgets('every sky the hero can paint clears 4.5:1 in ink',
      (tester) async {
    // The Living Field hero puts the greeting, the temperature and the primary
    // action directly on a gradient that follows the real clock and the real
    // weather. Every mood it can choose must therefore hold its own ink at both
    // stops — a dusk sky that only works at the top of the gradient would fail
    // exactly where the temperature sits.
    final hours = [0, 6, 9, 14, 17, 21];
    final icons = ['sunny', 'cloudy', 'rainy'];
    final failures = <String>[];

    for (final hour in hours) {
      for (final icon in icons) {
        final sky = skyFor(
          now: DateTime(2026, 10, 18, hour),
          iconCode: icon,
        );
        for (final (stop, colour) in [('top', sky.top), ('bottom', sky.bottom)]) {
          final ratio = contrast(sky.ink, colour);
          if (ratio < 4.5) {
            failures.add(
              '${sky.mood.name} $hour h $icon ($stop) = '
              '${ratio.toStringAsFixed(2)}:1',
            );
          }
        }
      }
    }

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  testWidgets('the sunlight sky clears 7:1 and is flat', (tester) async {
    final sky = skyFor(
      now: DateTime(2026, 10, 18, 17),
      iconCode: 'rainy',
      highContrast: true,
    );
    expect(sky.top, sky.bottom,
        reason: 'sunlight mode drops the gradient, not just the motion');
    expect(contrast(sky.ink, sky.flat), greaterThanOrEqualTo(7.0));
  });

  testWidgets('high-contrast mode really is higher contrast', (tester) async {
    // Guards against someone "fixing" a failure by darkening the light theme
    // until the two modes are the same thing.
    final lightBody = contrast(
      AppPalette.light.onSurface,
      AppPalette.light.background,
    );
    final hcBody = contrast(
      AppPalette.highContrast.onSurface,
      AppPalette.highContrast.background,
    );
    expect(hcBody, greaterThan(lightBody));

    final lightList = _pairs(AppPalette.light);
    final hcList = _pairs(AppPalette.highContrast);
    expect(hcList.length, lightList.length,
        reason: 'both palettes must cover the same roles');
  });
}
