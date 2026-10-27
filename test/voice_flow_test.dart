import 'package:agrisense/core/providers/settings_provider.dart';
import 'package:agrisense/core/voice/speech_recognizer.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:agrisense/data/models/voice.dart';
import 'package:agrisense/data/providers.dart';
import 'package:agrisense/features/market/market_screen.dart';
import 'package:agrisense/features/voice/voice_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A recogniser that answers on demand, so the whole state machine can be
/// driven without a microphone.
class _FakeRecognizer implements SpeechRecognizer {
  _FakeRecognizer({this.ready = true});

  final bool ready;
  void Function(SpeechHeard)? _onHeard;
  void Function()? _onDone;
  bool cancelled = false;

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
    _onDone = onDone;
  }

  void say(String text, {bool isFinal = true}) =>
      _onHeard?.call(SpeechHeard(text: text, isFinal: isFinal));

  void stopWithoutSpeech() => _onDone?.call();

  @override
  Future<void> cancel() async {
    cancelled = true;
  }
}

late SharedPreferences _prefs;

ProviderContainer _container(_FakeRecognizer recognizer) {
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(_prefs),
      speechRecognizerProvider.overrideWithValue(recognizer),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'settings.language': 'bn',
      'settings.language_chosen': true,
      'settings.consent_given': true,
    });
    _prefs = await SharedPreferences.getInstance();
  });

  test('a device with no microphone fails into the explain-and-type state',
      () async {
    final container = _container(_FakeRecognizer(ready: false));
    final controller = container.read(voiceControllerProvider.notifier);

    await controller.start();

    final state = container.read(voiceControllerProvider);
    expect(state, isA<VoiceFailed>());
    expect((state as VoiceFailed).reason, VoiceFailure.noMicrophone);
  });

  test('a spoken phrase reaches the understood state and names its screen',
      () async {
    final recognizer = _FakeRecognizer();
    final container = _container(recognizer);
    final controller = container.read(voiceControllerProvider.notifier);

    await controller.start();
    expect(container.read(voiceControllerProvider), isA<VoiceListening>());

    recognizer.say('বাজারে যাও');
    // The mock agent has real latency, so wait for it rather than pumping.
    await Future<void>.delayed(const Duration(milliseconds: 1700));

    final state = container.read(voiceControllerProvider);
    expect(state, isA<VoiceUnderstood>());
    expect((state as VoiceUnderstood).destination, VoiceDestination.haatBazar);
  });

  test('a silent session offers options instead of hanging', () async {
    final recognizer = _FakeRecognizer();
    final container = _container(recognizer);
    final controller = container.read(voiceControllerProvider.notifier);

    await controller.start();
    recognizer.stopWithoutSpeech();

    final state = container.read(voiceControllerProvider);
    expect(state, isA<VoiceClarifying>());
    expect((state as VoiceClarifying).choices, hasLength(3));
  });

  test('nonsense offers the main actions and never acts', () async {
    final container = _container(_FakeRecognizer());
    final controller = container.read(voiceControllerProvider.notifier);

    await controller.submitText('আকাশে তারা ভাসছে');

    final state = container.read(voiceControllerProvider);
    expect(state, isA<VoiceClarifying>());
    final choices = (state as VoiceClarifying).choices;
    expect(choices.map((c) => c.labelKey), contains('navMarket'));
  });

  test('a search sets the market filter and reports what was found', () async {
    final container = _container(_FakeRecognizer());
    final controller = container.read(voiceControllerProvider.notifier);

    await controller.submitText('ছত্রাকনাশক দেখাও');

    final state = container.read(voiceControllerProvider) as VoiceUnderstood;
    expect(state.destination, VoiceDestination.haatBazar);
    expect(state.products, isNotEmpty);
    // The farmer must land on the results, not on an empty search box.
    expect(container.read(marketFilterProvider).category, 'fungicide');
  });

  test('an order waits for an explicit yes, and a no leaves no order',
      () async {
    final container = _container(_FakeRecognizer());
    final controller = container.read(voiceControllerProvider.notifier);
    final market = container.read(marketRepositoryProvider);
    final before = (await market.orders()).length;

    await controller.submitText('দুই বোতল ছত্রাকনাশক অর্ডার করো');
    expect(container.read(voiceControllerProvider), isA<VoiceConfirming>());

    controller.decline();

    expect(container.read(voiceControllerProvider), isA<VoiceIdle>());
    expect((await market.orders()).length, before,
        reason: 'declining a voice order must not create one');
  });

  test('confirming places one order, marked as placed by voice', () async {
    final container = _container(_FakeRecognizer());
    final controller = container.read(voiceControllerProvider.notifier);
    final market = container.read(marketRepositoryProvider);

    await controller.submitText('এক বোতল ছত্রাকনাশক অর্ডার করো');
    final confirming = container.read(voiceControllerProvider);
    expect(confirming, isA<VoiceConfirming>());
    final quantity = (confirming as VoiceConfirming).quantity;

    await controller.confirm();

    expect(container.read(voiceControllerProvider), isA<VoicePlaced>());
    final orders = await market.orders();
    final placed = orders.first;
    expect(placed.placedVia, InputMode.voice);
    expect(placed.items.single.quantity, quantity);
  });

  test('a tapped option runs the same path as a spoken phrase', () async {
    final container = _container(_FakeRecognizer());
    final controller = container.read(voiceControllerProvider.notifier);

    await controller.submitText('আকাশে তারা ভাসছে');
    final choice = (container.read(voiceControllerProvider) as VoiceClarifying)
        .choices
        .firstWhere((c) => c.labelKey == 'navMarket');

    await controller.runChoice(choice.command);

    final state = container.read(voiceControllerProvider) as VoiceUnderstood;
    expect(state.destination, VoiceDestination.haatBazar);
  });

  test('using the touch path cancels listening', () async {
    final recognizer = _FakeRecognizer();
    final container = _container(recognizer);
    final controller = container.read(voiceControllerProvider.notifier);

    await controller.start();
    await controller.cancel();

    expect(recognizer.cancelled, isTrue);
    expect(container.read(voiceControllerProvider), isA<VoiceIdle>());
  });
}
