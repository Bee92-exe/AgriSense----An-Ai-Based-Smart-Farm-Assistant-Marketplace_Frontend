import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/providers/settings_provider.dart';
import 'core/router/app_router.dart';
import 'data/providers.dart';
import 'core/theme/app_scroll_behavior.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

/// Root widget.
///
/// Three settings drive everything visible: the language decides the locale and
/// therefore every string and digit in the app, and the high-contrast flag swaps
/// the entire palette. Both are read from one provider so a change repaints the
/// app without a restart.
class AgriSenseApp extends ConsumerStatefulWidget {
  const AgriSenseApp({super.key});

  @override
  ConsumerState<AgriSenseApp> createState() => _AgriSenseAppState();
}

class _AgriSenseAppState extends ConsumerState<AgriSenseApp> {
  @override
  void initState() {
    super.initState();
    // Photos captured without a connection are sent as soon as the app opens
    // with one. Failures are swallowed here: the farmer did not ask for this
    // upload, so it must never surface as an error on the home screen.
    Future<void>.microtask(() async {
      try {
        await ref.read(diagnosisQueueProvider).flush();
      } catch (_) {
        // Still offline, or storage unavailable. The queue is durable; the next
        // launch tries again.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AgriSense',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      scrollBehavior: const AppScrollBehavior(),
      theme: settings.highContrast ? AppTheme.highContrast() : AppTheme.light(),
      locale: Locale(settings.language),
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppL10n.supportedLocales,
      // Bangla first: if a locale is somehow unavailable, a farmer must not fall
      // back to English.
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('bn');
        for (final s in supported) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return const Locale('bn');
      },
      builder: (context, child) {
        // Nothing in this app should ever be smaller than the design system's
        // floor, so the text scale is clamped rather than allowed to go to a
        // value the layouts were never tested against. Up to 1.3x is required to
        // work and is verified by the widget tests.
        final media = MediaQuery.of(context);
        final scale = media.textScaler.clamp(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
        );
        return MediaQuery(
          data: media.copyWith(textScaler: scale),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Warms the date formatting data before the first frame.
///
/// `DateFormat` throws for a locale that has not been initialised, and a farmer
/// seeing an exception on the splash screen for a Bangla date would be a
/// first-impression bug.
Future<void> initialiseLocalisationData() async {
  await initializeDateFormatting('bn', null);
  await initializeDateFormatting('en', null);
}
