import 'package:agrisense/core/providers/settings_provider.dart';
import 'package:agrisense/core/providers/session_provider.dart';
import 'package:agrisense/core/theme/app_theme.dart';
import 'package:agrisense/core/voice/speaker.dart';
import 'package:agrisense/core/widgets/app_button.dart';
import 'package:agrisense/core/voice/speech_recognizer.dart';
import 'package:agrisense/data/mock/mock_repositories.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:agrisense/data/models/user.dart';
import 'package:agrisense/features/assistant/assistant_screen.dart';
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

Widget _host(Widget screen) => ProviderScope(
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
        home: screen,
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

  group('the mock knowledge base', () {
    late MockVoiceRepository voice;

    setUp(() => voice = MockVoiceRepository(config: MockConfig()));

    test('a known question is answered with its source', () async {
      final answer = await voice.ask('ধানে ব্লাস্ট হলে কী করব?');

      expect(answer.found, isTrue);
      expect(answer.sources, isNotEmpty);
      expect(answer.sources.first.title, contains('BRRI'));
      expect(answer.offerExpert, isFalse);
    });

    test('an unknown question is refused, not guessed', () async {
      final answer = await voice.ask('আকাশের রং নীল কেন?');

      expect(answer.found, isFalse);
      expect(answer.offerExpert, isTrue,
          reason: 'the farmer must be offered a human instead of a guess');
    });

    test('no answer states a dose', () async {
      // knowledge.md: the app may not produce a pesticide quantity it cannot
      // cite, so no knowledge-base answer may contain a number at all.
      for (final question in ['ব্লাস্ট', 'নাবি ধসা', 'সার', 'পোকা']) {
        final answer = await voice.ask(question);
        expect(
          RegExp(r'[০-৯0-9]').hasMatch(answer.answerText),
          isFalse,
          reason: 'answer for "$question" contains a number: ${answer.answerText}',
        );
      }
    });

    test('an empty question asks for a repeat instead of answering', () async {
      final answer = await voice.ask('   ');
      expect(answer.found, isFalse);
    });
  });

  group('the assistant screen', () {
    testWidgets('a typed question shows an answer with its source',
        (tester) async {
      await tester.pumpWidget(_host(const AssistantScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ব্লাস্ট');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await _settle(tester);

      expect(find.text('সূত্র'), findsOneWidget);
      expect(find.textContaining('BRRI'), findsOneWidget);
      // And it is remembered for the session.
      expect(find.text('আগের প্রশ্ন'), findsOneWidget);
    });

    testWidgets('an unanswerable question offers an expert, not a guess',
        (tester) async {
      await tester.pumpWidget(_host(const AssistantScreen()));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'আকাশের রং নীল কেন?');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await _settle(tester);

      // The refusal is shown, and the way out is a person.
      expect(find.text('এই উত্তর আমার কাছে নেই'), findsWidgets);
      expect(
        find.ancestor(
          of: find.text('বিশেষজ্ঞকে পাঠান'),
          matching: find.byType(AppButton),
        ),
        findsOneWidget,
      );
    });
  });
}
