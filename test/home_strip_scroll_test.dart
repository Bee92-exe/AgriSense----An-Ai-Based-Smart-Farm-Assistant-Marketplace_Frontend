import 'package:agrisense/core/providers/session_provider.dart';
import 'package:agrisense/core/providers/settings_provider.dart';
import 'package:agrisense/core/theme/app_scroll_behavior.dart';
import 'package:agrisense/core/theme/app_theme.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:agrisense/data/models/user.dart';
import 'package:agrisense/features/home/home_screen.dart';
import 'package:agrisense/l10n/app_localizations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The reported bug: on the web build the Home photo strip could not be
/// scrolled sideways at all.
///
/// Two things were wrong. Flutter's default scroll behaviour does not accept a
/// mouse as a drag device, so a mouse could never move a horizontal list; and
/// the strip sits below the fold, so a drag aimed at where it *looks* like it
/// should be lands on the nav bar. Both are covered here: the second test fails
/// if [AppScrollBehavior] is ever dropped from `MaterialApp`.
const _farmer = AppUser(
  id: 'usr-0001',
  name: 'আব্দুল করিম',
  mobile: '01711000001',
  role: Role.farmer,
  status: AccountStatus.active,
  district: 'ঢাকা',
);

late SharedPreferences _prefs;

Widget _host(Widget screen, {bool withScrollBehavior = true}) => ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_prefs),
        currentUserProvider.overrideWithValue(_farmer),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('bn'),
        scrollBehavior:
            withScrollBehavior ? const AppScrollBehavior() : null,
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

/// Pumps Home, scrolls to the bottom, and hands back the horizontal strip's
/// scroll position.
Future<ScrollPosition> _openStrip(
  WidgetTester tester, {
  bool withScrollBehavior = true,
}) async {
  tester.view.physicalSize = const Size(412, 915);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    _host(const HomeScreen(), withScrollBehavior: withScrollBehavior),
  );
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }

  // The page is taller than the screen; the strip is at the bottom of it.
  final page = tester.state<ScrollableState>(find.byType(Scrollable).first)
      .position;
  page.jumpTo(page.maxScrollExtent);
  await tester.pumpAndSettle();

  final strip = find.byWidgetPredicate(
    (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
  );
  expect(strip, findsOneWidget, reason: 'the photo strip should be present');

  return tester
      .state<ScrollableState>(
        find.descendant(of: strip, matching: find.byType(Scrollable)),
      )
      .position;
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

  test('a mouse and a trackpad count as drag devices', () {
    expect(
      const AppScrollBehavior().dragDevices,
      contains(PointerDeviceKind.mouse),
    );
    expect(
      const AppScrollBehavior().dragDevices,
      contains(PointerDeviceKind.trackpad),
    );
  });

  testWidgets('the recent photo strip drags sideways with a mouse',
      (tester) async {
    final position = await _openStrip(tester);

    expect(position.maxScrollExtent, greaterThan(0),
        reason: 'the strip has to be wider than the screen to be scrollable');
    expect(position.pixels, 0);

    // A real mouse drag on the card area of the strip, not on the mic that
    // floats over its middle.
    final strip = find.byWidgetPredicate(
      (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
    );
    await tester.dragFrom(
      tester.getTopLeft(strip) + const Offset(80, 60),
      const Offset(-200, 0),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();

    expect(
      position.pixels,
      greaterThan(0),
      reason: 'dragging the strip with a mouse must move it',
    );
  });
}
