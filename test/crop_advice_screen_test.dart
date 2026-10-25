import 'package:agrisense/core/providers/settings_provider.dart';
import 'package:agrisense/core/providers/session_provider.dart';
import 'package:agrisense/core/theme/app_theme.dart';
import 'package:agrisense/core/voice/speaker.dart';
import 'package:agrisense/core/voice/speech_recognizer.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:agrisense/data/models/user.dart';
import 'package:agrisense/features/crop_advice/crop_advice_screen.dart';
import 'package:agrisense/features/voice/voice_controller.dart';
import 'package:agrisense/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SilentRecognizer implements SpeechRecognizer {
  @override
  bool get isListening => false;

  @override
  Future<bool> prepare() async => false;

  @override
  Future<void> start({
    required void Function(SpeechHeard) onHeard,
    required void Function(double level) onLevel,
    required void Function() onDone,
    Duration listenFor = const Duration(seconds: 15),
  }) async =>
      onDone();

  @override
  Future<void> cancel() async {}
}

const _farmer = AppUser(
  id: 'usr-0001',
  name: 'আব্দুল করিম',
  mobile: '01711000001',
  role: Role.farmer,
  status: AccountStatus.active,
  district: 'ঢাকা',
);

late SharedPreferences _prefs;

Widget _host() => ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_prefs),
        currentUserProvider.overrideWithValue(_farmer),
        speakerProvider.overrideWithValue(const SilentSpeaker()),
        speechRecognizerProvider.overrideWithValue(_SilentRecognizer()),
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
        home: const CropAdviceScreen(),
      ),
    );

Future<void> _settle(WidgetTester tester, {int steps = 10}) async {
  for (var i = 0; i < steps; i++) {
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

  testWidgets('the farmer picks a soil and gets three ranked crops',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host());
    await _settle(tester);

    // The form arrives from the reference lists, with the farmer's own district
    // already in place.
    expect(find.text('মাটির ধরন'), findsOneWidget);
    expect(find.text('ঢাকা'), findsWidgets);

    await tester.tap(find.text('দোআঁশ মাটি'));
    await _settle(tester, steps: 2);

    // The form is taller than the viewport, so the action has to be scrolled to
    // exactly as a farmer would scroll to it.
    await tester.ensureVisible(find.text('পরামর্শ দিন'));
    await _settle(tester, steps: 2);
    await tester.tap(find.text('পরামর্শ দিন'));
    await _settle(tester);
    await tester.ensureVisible(find.text('আপনার জন্য তিনটি ফসল'));
    await _settle(tester, steps: 2);

    expect(find.text('আপনার জন্য তিনটি ফসল'), findsOneWidget);
    expect(find.text('আবহাওয়া মিলিয়ে দেখা হয়েছে'), findsOneWidget);
    // Ranked 1..3 in Bangla digits, each with the reason it earned.
    for (final rank in ['১', '২', '৩']) {
      expect(find.text(rank), findsOneWidget);
    }
    expect(find.textContaining('মৌসুমে'), findsWidgets);

    // And the answer joins the saved list on the same screen.
    expect(find.text('আগের পরামর্শ'), findsOneWidget);
  });

  testWidgets('advice cannot be asked for before a soil is chosen',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host());
    await _settle(tester);

    final button = tester.widget<FilledButton>(
      find.descendant(
        of: find.byType(SizedBox),
        matching: find.byType(FilledButton),
      ).first,
    );
    expect(button.onPressed, isNull,
        reason: 'the button must say there is nothing to recommend from yet');
  });
}
