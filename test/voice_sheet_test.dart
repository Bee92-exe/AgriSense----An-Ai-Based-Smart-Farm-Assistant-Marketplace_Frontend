import 'package:agrisense/core/providers/settings_provider.dart';
import 'package:agrisense/core/router/app_router.dart';
import 'package:agrisense/core/theme/app_theme.dart';
import 'package:agrisense/core/voice/speaker.dart';
import 'package:agrisense/core/voice/speech_recognizer.dart';
import 'package:agrisense/data/providers.dart';
import 'package:agrisense/features/voice/voice_controller.dart';
import 'package:agrisense/l10n/app_localizations.dart';
import 'package:agrisense/shell/farmer_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The voice sheet, driven the way a farmer drives it: tap the microphone, then
/// either speak or type.
///
/// This is the check that matters for "does voice work at all" — the unit tests
/// cover the state machine, this one covers the wiring from the global mic to a
/// real screen change.
class _FakeRecognizer implements SpeechRecognizer {
  _FakeRecognizer({this.ready = true});

  final bool ready;
  void Function(SpeechHeard)? _onHeard;

  @override
  bool get isListening => true;

  @override
  Future<bool> prepare() async => ready;

  @override
  Future<void> start({
    required void Function(SpeechHeard) onHeard,
    required void Function(double level) onLevel,
    required void Function() onDone,
    Duration listenFor = const Duration(seconds: 15),
  }) async {
    _onHeard = onHeard;
  }

  void say(String text) =>
      _onHeard?.call(SpeechHeard(text: text, isFinal: true));

  @override
  Future<void> cancel() async {}
}

late SharedPreferences _prefs;
late ProviderContainer _container;

Widget _host(GoRouter router) => UncontrolledProviderScope(
      container: _container,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        locale: const Locale('bn'),
        routerConfig: router,
        localizationsDelegates: const [
          AppL10n.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppL10n.supportedLocales,
      ),
    );

GoRouter _router() => GoRouter(
      initialLocation: Routes.home,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (_, _) => const Scaffold(
            body: Center(child: FarmerMicFab()),
          ),
        ),
        GoRoute(
          path: Routes.market,
          builder: (_, _) => const Scaffold(body: Text('MARKET SCREEN')),
        ),
        GoRoute(
          path: Routes.weather,
          builder: (_, _) => const Scaffold(body: Text('WEATHER SCREEN')),
        ),
      ],
    );

/// Pumps long enough for the mock agent's latency and the sheet's farewell.
///
/// Bounded pumps only: the sheet shows a spinner while it works, so
/// `pumpAndSettle` would wait for an animation that never ends.
Future<void> _settle(WidgetTester tester, {int steps = 12}) async {
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

/// Opens the sheet from the microphone and lets it reach its first state.
Future<void> _openSheet(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.mic_rounded));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
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

  testWidgets('the mic opens the sheet and a spoken command changes screen',
      (tester) async {
    final recognizer = _FakeRecognizer();
    _container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_prefs),
        speechRecognizerProvider.overrideWithValue(recognizer),
        speakerProvider.overrideWithValue(const SilentSpeaker()),
      ],
    );
    addTearDown(_container.dispose);

    await tester.pumpWidget(_host(_router()));
    await tester.pumpAndSettle();

    await _openSheet(tester);

    // The sheet is up and listening.
    expect(find.textContaining('বলুন'), findsOneWidget);

    recognizer.say('বাজারে যাও');
    await _settle(tester);

    expect(find.text('MARKET SCREEN'), findsOneWidget);
    expect(find.textContaining('বলুন'), findsNothing,
        reason: 'the sheet must close once the command has been carried out');
  });

  testWidgets('with no microphone the sheet explains and still works by typing',
      (tester) async {
    _container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_prefs),
        speechRecognizerProvider
            .overrideWithValue(_FakeRecognizer(ready: false)),
        speakerProvider.overrideWithValue(const SilentSpeaker()),
      ],
    );
    addTearDown(_container.dispose);

    await tester.pumpWidget(_host(_router()));
    await tester.pumpAndSettle();

    await _openSheet(tester);

    expect(find.textContaining('লিখে'), findsWidgets,
        reason: 'the farmer is told to type instead of being left stuck');

    await tester.enterText(find.byType(TextField), 'বাজারে যাও');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _settle(tester);

    expect(find.text('MARKET SCREEN'), findsOneWidget);
  });

  testWidgets('an order is never placed without pressing confirm',
      (tester) async {
    _container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_prefs),
        speechRecognizerProvider
            .overrideWithValue(_FakeRecognizer(ready: false)),
        speakerProvider.overrideWithValue(const SilentSpeaker()),
      ],
    );
    addTearDown(_container.dispose);

    await tester.pumpWidget(_host(_router()));
    await tester.pumpAndSettle();
    await _openSheet(tester);

    await tester.enterText(
      find.byType(TextField),
      'এক বোতল ছত্রাকনাশক অর্ডার করো',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await _settle(tester);

    // Waiting for a decision, and nothing bought yet.
    expect(find.text('হ্যাঁ, অর্ডার করুন'), findsOneWidget);
    final market = _container.read(marketRepositoryProvider);
    // `runAsync` because the mock repository waits on a real timer, which the
    // test clock does not advance on its own.
    final before = (await tester.runAsync(market.orders))!.length;

    // The cancel route must leave no order behind.
    await tester.tap(find.text('বাতিল করুন'));
    await _settle(tester, steps: 4);
    final after = (await tester.runAsync(market.orders))!.length;
    expect(after, before);
  });
}
