import 'dart:async';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// One recogniser session's output.
class SpeechHeard {
  const SpeechHeard({required this.text, required this.isFinal});

  final String text;

  /// True when the recogniser has stopped refining this utterance. The sheet
  /// shows partial text while listening so the farmer can see they are being
  /// heard, and only acts on a final one.
  final bool isFinal;
}

/// What the app needs from speech-to-text, and nothing more.
///
/// An interface rather than the plugin directly, for two reasons: the voice
/// sheet must be testable without a microphone, and on a device where speech is
/// unavailable (desktop web without the Web Speech API, a phone with the
/// service switched off) the app needs a defined "unavailable" answer instead
/// of an exception at an unpredictable moment.
abstract interface class SpeechRecognizer {
  /// Prepares the recogniser and asks for the microphone if it has not been
  /// granted yet. Returns false when speech cannot be used on this device —
  /// never throws, because "no microphone here" is not an app failure.
  Future<bool> prepare();

  bool get isListening;

  /// Starts one bounded session. [onHeard] fires for partial and final results,
  /// [onLevel] with a 0-10 sound level for the meter.
  Future<void> start({
    required void Function(SpeechHeard) onHeard,
    required void Function(double level) onLevel,
    required void Function() onDone,
    Duration listenFor,
  });

  /// Stops and discards the audio (the "cancel" path).
  Future<void> cancel();
}

/// The real device recogniser.
class DeviceSpeechRecognizer implements SpeechRecognizer {
  DeviceSpeechRecognizer({SpeechToText? speech}) : _speech = speech ?? SpeechToText();

  final SpeechToText _speech;
  bool _ready = false;
  Timer? _poll;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<bool> prepare() async {
    if (_ready) return true;
    try {
      _ready = await _speech.initialize();
    } catch (_) {
      // A missing permission or an absent speech service surfaces as a throw on
      // some platforms; both mean the same thing to the caller.
      _ready = false;
    }
    return _ready;
  }

  @override
  Future<void> start({
    required void Function(SpeechHeard) onHeard,
    required void Function(double level) onLevel,
    required void Function() onDone,
    Duration listenFor = const Duration(seconds: 15),
  }) async {
    await _speech.listen(
      onResult: (SpeechRecognitionResult result) => onHeard(
        SpeechHeard(
          text: result.recognizedWords,
          isFinal: result.finalResult,
        ),
      ),
      onSoundLevelChange: onLevel,
      // Bangla first: the app is Bangla-first and a farmer's command will be in
      // Bangla. The plugin falls back to the device default when the locale is
      // not installed, which is the best available answer on such a phone.
      localeId: 'bn_BD',
      listenFor: listenFor,
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(cancelOnError: true),
    );

    // The plugin reports "I stopped listening" through the status callback of
    // `initialize`, which is set up once, not per session. Polling the flag is
    // the only per-session way to learn that a silent session has ended, and it
    // matters: without it a farmer who says nothing waits out the whole window
    // before the sheet offers options.
    _poll?.cancel();
    var started = false;
    final deadline = DateTime.now().add(listenFor + const Duration(seconds: 3));
    _poll = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (_speech.isListening) {
        started = true;
        return;
      }
      if (!started && DateTime.now().isBefore(deadline)) return;
      timer.cancel();
      onDone();
    });
  }

  @override
  Future<void> cancel() async {
    _poll?.cancel();
    try {
      await _speech.cancel();
    } catch (_) {
      // Nothing to cancel is not an error.
    }
  }
}

/// Used on platforms where the app is running but speech is not: the sheet
/// skips straight to the typed-command path instead of pretending to listen.
class UnavailableSpeechRecognizer implements SpeechRecognizer {
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
