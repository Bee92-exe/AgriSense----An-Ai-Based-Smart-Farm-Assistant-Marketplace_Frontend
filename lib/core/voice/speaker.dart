import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../data/providers.dart';
import 'server_speaker.dart';

/// Reading things out loud.
///
/// Voice output is an *enhancement* everywhere it is used: the same words are on
/// screen, so a device without a Bangla voice (or with the sound muted) loses
/// nothing but the audio. Every method therefore swallows platform failures and
/// reports them through [isAvailable] instead of throwing into a build method.
abstract interface class Speaker {
  /// False when this device cannot speak — the UI then hides the speaker icon
  /// rather than offering a control that does nothing.
  bool get isAvailable;

  Future<void> speak(String text, {required String languageCode});

  Future<void> stop();
}

class TtsSpeaker implements Speaker {
  TtsSpeaker({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  final Map<String, Map<String, String>?> _voiceCache = {};
  bool _configured = false;

  /// Optimistic until a call fails: the plugin offers no way to ask whether a
  /// voice exists, so the first failure is what tells us.
  bool _available = true;

  @override
  bool get isAvailable => _available;

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    if (text.trim().isEmpty) return;
    final tag = languageCode == 'en' ? 'en-US' : 'bn-BD';
    try {
      await _configure(tag);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      _available = false;
    }
  }

  /// Sets the locale *and* an explicit voice for it.
  ///
  /// Choosing the voice matters: `setLanguage('bn-BD')` alone leaves the engine
  /// on whatever voice it already had, which is how Bangla treatment steps ended
  /// up read out by an English voice. When the device has a Bangla voice it is
  /// now selected deliberately, preferring a feminine one; when it has none the
  /// call fails quietly and the screen text still carries the answer.
  Future<void> _configure(String tag) async {
    try {
      await _tts.setLanguage(tag);
    } catch (_) {
      // No Bangla engine: text still shows, so this is not fatal.
    }
    try {
      final voice = await _voiceFor(tag);
      if (voice != null) await _tts.setVoice(voice);
    } catch (_) {
      // A rejected voice must not stop playback of the fallback voice.
    }
    try {
      await _tts.setPitch(tag.startsWith('bn') ? 1.15 : 1.0);
      await _tts.setSpeechRate(0.45);
    } catch (_) {
      _available = false;
    }
    if (_configured) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setVolume(1);
    } catch (_) {
      _available = false;
    }
    _configured = true;
  }

  /// The first voice whose locale matches, preferring a feminine name.
  Future<Map<String, String>?> _voiceFor(String tag) async {
    if (_voiceCache.containsKey(tag)) return _voiceCache[tag];
    Map<String, String>? chosen;
    try {
      final raw = await _tts.getVoices;
      final prefix = tag.split('-').first.toLowerCase();
      final candidates = <Map<String, String>>[];
      for (final entry in (raw as List?) ?? const []) {
        if (entry is! Map) continue;
        final locale =
            (entry['locale'] ?? entry['language'] ?? '').toString().toLowerCase();
        if (!locale.startsWith(prefix)) continue;
        candidates.add({
          'name': (entry['name'] ?? '').toString(),
          'locale': locale,
        });
      }
      if (candidates.isNotEmpty) {
        chosen = candidates.firstWhere(_isFeminine, orElse: () => candidates.first);
      }
    } catch (_) {
      chosen = null;
    }
    _voiceCache[tag] = chosen;
    return chosen;
  }

  /// Voice names are the only signal the platform gives us. Google's Bangla
  /// voice and the common bn-BD system voices are female, so a Bangla match is
  /// treated as feminine unless the name says otherwise.
  static bool _isFeminine(Map<String, String> voice) {
    final name = (voice['name'] ?? '').toLowerCase();
    if (name.contains('female') || name.contains('woman')) return true;
    if (name.contains('male') && !name.contains('female')) return false;
    return (voice['locale'] ?? '').startsWith('bn');
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Nothing playing.
    }
  }
}

/// One speaker for the whole app.
///
/// Server synthesis is the primary voice, because a phone without a Bangla voice
/// reads Bangla text in English; the device voice is the fallback for when the
/// server has no TTS key or the network is down.
///
/// Deliberately not auto-disposed: the voice sheet is dismissed as soon as a
/// command is understood, and the spoken confirmation would be cut off if the
/// speaker died with the widget that started it.
final speakerProvider = Provider<Speaker>((ref) {
  return FallbackSpeaker(
    primary: ServerTtsSpeaker(client: ref.watch(apiClientProvider)),
    fallback: TtsSpeaker(),
  );
});

/// The no-op speaker used in tests and on platforms with no TTS at all.
class SilentSpeaker implements Speaker {
  const SilentSpeaker();

  @override
  bool get isAvailable => false;

  @override
  Future<void> speak(String text, {required String languageCode}) async {}

  @override
  Future<void> stop() async {}
}
