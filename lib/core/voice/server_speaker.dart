import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';

import '../../data/remote/api_client.dart';
import '../../data/repositories/auth_repository.dart' show ApiException;
import 'speaker.dart';

/// Speaks using audio synthesised by our own server.
///
/// Many Android phones sold in Bangladesh have no Bangla voice installed, so
/// device TTS reads Bangla text with an English voice. Synthesising on the
/// server (`POST /ai/tts`, Google Cloud bn-BD, female) gives every phone the same
/// voice instead of depending on what the phone shipped with.
///
/// This is best-effort like every other speaker: if the server has no TTS key or
/// the network drops, [isAvailable] turns false and [FallbackSpeaker] hands the
/// same text to the device voice.
class ServerTtsSpeaker implements Speaker {
  ServerTtsSpeaker({required ApiClient client, AudioPlayer? player})
      : _client = client,
        _player = player;

  /// One request is capped server-side; longer answers are split on sentence
  /// boundaries so a full treatment is still read end to end.
  static const int _chunkChars = 1700;

  final ApiClient _client;
  AudioPlayer? _player;

  bool _available = true;

  @override
  bool get isAvailable => _available;

  AudioPlayer get _audio => _player ??= AudioPlayer();

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    if (!_available || text.trim().isEmpty) return;

    final language = languageCode == 'en' ? 'en' : 'bn';
    for (final chunk in _chunks(text)) {
      try {
        final response = await _client.post(
          '/ai/tts',
          body: {'text': chunk, 'language': language},
        );
        final audio = response['audio_base64'];
        if (audio is! String || audio.isEmpty) {
          _available = false;
          return;
        }
        await _audio.stop();
        await _audio.play(
          BytesSource(
            base64Decode(audio),
            mimeType: response['mime_type'] as String? ?? 'audio/mpeg',
          ),
        );
        // Finish this sentence before requesting the next one, so the answer is
        // not spoken over itself.
        await _audio.onPlayerComplete.first.timeout(
          const Duration(seconds: 60),
          onTimeout: () {},
        );
      } on ApiException catch (error) {
        // 503 means the server has no TTS key: that will not fix itself this
        // session, so stop trying and let the device voice take over. A 4xx on
        // one chunk is about that text only and must not disable the feature.
        if (error.statusCode == 503 || error.code == 'network_error') {
          _available = false;
        }
        return;
      } catch (_) {
        _available = false;
        return;
      }
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audio.stop();
    } catch (_) {
      // Nothing playing.
    }
  }

  /// Splits on Bangla/English sentence ends, never inside a sentence.
  static List<String> _chunks(String text) {
    final sentences = text
        .split(RegExp(r'[।!?\n]+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty);

    final chunks = <String>[];
    var buffer = '';
    for (final sentence in sentences) {
      final piece = sentence.length > _chunkChars
          ? sentence.substring(0, _chunkChars)
          : sentence;
      if (buffer.isEmpty) {
        buffer = piece;
      } else if (buffer.length + piece.length + 2 <= _chunkChars) {
        buffer = '$buffer। $piece';
      } else {
        chunks.add(buffer);
        buffer = piece;
      }
    }
    if (buffer.isNotEmpty) chunks.add(buffer);
    return chunks.isEmpty ? <String>[text.trim()] : chunks;
  }
}

/// Uses the server voice when it works and the device voice when it does not.
///
/// `isAvailable` is true when *either* can speak, so the read-aloud control only
/// disappears when there is genuinely no way to hear the answer.
class FallbackSpeaker implements Speaker {
  FallbackSpeaker({required this.primary, required this.fallback});

  final Speaker primary;
  final Speaker fallback;

  @override
  bool get isAvailable => primary.isAvailable || fallback.isAvailable;

  @override
  Future<void> speak(String text, {required String languageCode}) async {
    if (primary.isAvailable) {
      await primary.speak(text, languageCode: languageCode);
      // The primary marks itself unavailable when it fails, which is the signal
      // to re-speak this same text through the fallback.
      if (primary.isAvailable) return;
    }
    await fallback.speak(text, languageCode: languageCode);
  }

  @override
  Future<void> stop() async {
    await primary.stop();
    await fallback.stop();
  }
}
