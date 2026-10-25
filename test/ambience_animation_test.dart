import 'package:agrisense/core/providers/session_provider.dart';
import 'package:agrisense/core/providers/settings_provider.dart';
import 'package:agrisense/core/theme/app_theme.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:agrisense/data/models/user.dart';
import 'package:agrisense/features/home/home_screen.dart';
import 'package:agrisense/features/market/market_screen.dart';
import 'package:agrisense/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The bug this file exists for: the অ্যানিমেশন switch flipped and stored, but
/// nothing on the page moved. Asserting the stored boolean was not enough — the
/// failure was that no ticker ever started. These tests assert exactly that: an
/// active frame callback while the mode is on, and a still tree while it is off.
const _farmer = AppUser(
  id: 'usr-0001',
  name: 'আব্দুল করিম',
  mobile: '01711000001',
  role: Role.farmer,
  status: AccountStatus.active,
  district: 'ঢাকা',
);

late SharedPreferences _prefs;

Widget _host(Widget screen) => ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_prefs),
        currentUserProvider.overrideWithValue(_farmer),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('bn'),
        localizationsDelegates: const [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppL10n.supportedLocales,
        home: screen,
      ),
    );

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 14; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('bn', null);
    await initializeDateFormatting('en', null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'settings.language': 'bn',
      'settings.language_chosen': true,
      'settings.consent_given': true,
    });
    _prefs = await SharedPreferences.getInstance();
  });

  for (final entry in <String, Widget Function()>{
    'home hero': () => const HomeScreen(),
    'market ambience': () => const MarketScreen(),
  }.entries) {
    testWidgets('${entry.key}: motion runs only in অ্যানিমেশন mode',
        (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Off by default: whatever the framework itself keeps running, the
      // ambience must not add a ticker on top of it.
      await tester.pumpWidget(_host(entry.value()));
      await _settle(tester);
      final idle = tester.binding.transientCallbackCount;

      // Turn it on the way a farmer does, through the settings notifier.
      final context = tester.element(find.byType(MaterialApp));
      final container = ProviderScope.containerOf(context);
      await container.read(settingsProvider.notifier).setAnimatedMode(true);
      await tester.pump();
      await _settle(tester);

      final moving = tester.binding.transientCallbackCount;
      expect(
        moving,
        greaterThan(idle),
        reason: 'the mode is on, so the ambience has to add motion '
            '(idle=$idle, moving=$moving)',
      );

      // And off again: the tickers have to stop, not just stop being painted.
      await container.read(settingsProvider.notifier).setAnimatedMode(false);
      await tester.pump();
      await _settle(tester);

      expect(
        tester.binding.transientCallbackCount,
        idle,
        reason: 'turning the mode off must stop the ticker, not hide it',
      );
    });
  }
}
