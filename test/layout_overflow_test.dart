import 'package:agrisense/core/providers/session_provider.dart';
import 'package:agrisense/core/providers/settings_provider.dart';
import 'package:agrisense/core/theme/app_theme.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:agrisense/data/models/user.dart';
import 'package:agrisense/features/assistant/assistant_screen.dart';
import 'package:agrisense/features/auth/login_screen.dart';
import 'package:agrisense/features/crop_advice/calendar_screen.dart';
import 'package:agrisense/features/crop_advice/crop_advice_screen.dart';
import 'package:agrisense/features/diagnosis/history_screen.dart';
import 'package:agrisense/features/diagnosis/result_screen.dart';
import 'package:agrisense/features/home/home_screen.dart';
import 'package:agrisense/features/market/market_screen.dart';
import 'package:agrisense/features/market/orders_screen.dart';
import 'package:agrisense/features/news/news_list_screen.dart';
import 'package:agrisense/features/profile/profile_screen.dart';
import 'package:agrisense/features/weather/weather_screen.dart';
import 'package:agrisense/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The app is built for a 56dp tap floor and Bangla at up to 1.3x, so 320dp is
/// the width every layout has to survive. An overflow here is a farmer seeing
/// their own language cut in half.
const _narrow = Size(320, 720);
const _phone = Size(412, 915);

const _farmer = AppUser(
  id: 'usr-0001',
  name: 'আব্দুল করিম',
  mobile: '01711000001',
  role: Role.farmer,
  status: AccountStatus.active,
  district: 'ঢাকা',
  farmSize: 2.5,
);

late SharedPreferences _prefs;

Widget _host(Widget screen) {
  return ProviderScope(
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
}

/// Pumps long enough for the mock repositories' real latency (300–1500ms) and
/// the loading skeletons to settle, then reports every layout exception.
Future<List<String>> _pumpAndCollect(WidgetTester tester, Widget screen) async {
  // Capture the full overflow report (it names the widget and the file) rather
  // than only the exception message `takeException` would hand back.
  final original = FlutterError.onError;
  final errors = <String>[];
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) {
      errors.add(details.toString());
    } else {
      original?.call(details);
    }
  };

  await tester.pumpWidget(_host(screen));
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }

  FlutterError.onError = original;
  return errors;
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

  final screens = <String, Widget Function()>{
    'home': () => const HomeScreen(),
    'market': () => const MarketScreen(),
    'history': () => const HistoryScreen(),
    'orders': () => const OrdersScreen(),
    'news': () => const NewsListScreen(),
    'result': () => const ResultScreen(diagnosisId: 'dx-2'),
    'profile': () => const ProfileScreen(),
    'weather': () => const WeatherScreen(),
    'login': () => const LoginScreen(),
    'advice': () => const CropAdviceScreen(),
    'calendar': () => const CalendarScreen(crop: 'rice'),
    'assistant': () => const AssistantScreen(),
  };

  for (final scale in [1.0, 1.3]) {
    for (final size in [_narrow, _phone]) {
      for (final entry in screens.entries) {
        testWidgets(
          '${entry.key} lays out at ${size.width.toInt()}dp x$scale',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

            final errors = await _pumpAndCollect(tester, entry.value());
            if (errors.isNotEmpty) {
              // ignore: avoid_print
              print(errors.first);
            }

            expect(
              errors,
              isEmpty,
              reason: '${entry.key} overflowed:\n${errors.join('\n')}',
            );
          },
        );
      }
    }
  }
}
