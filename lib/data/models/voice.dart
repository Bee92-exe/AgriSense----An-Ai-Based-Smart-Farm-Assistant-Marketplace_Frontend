import 'package:flutter/foundation.dart';

/// What the farmer asked for. The set is deliberately small: `VOICE_UX.md`
/// restricts voice to a closed allowlist, and anything outside it must be
/// refused out loud rather than guessed at.
enum VoiceIntent {
  /// Open one of the app's screens ([VoiceCommand.destination]).
  navigate('navigate'),

  /// Weather for the farmer's district.
  weather('get_weather'),

  /// Find products in Haat_Bazar and read the top few back.
  searchProduct('search_product'),

  /// Buy something. Always ends in an explicit confirmation.
  orderProduct('order_product'),

  /// A real question, not a command ("ধানে বাদামি দাগ হলে কী করব?").
  ask('ask'),

  /// Nothing in the allowlist matched, or nothing was understood.
  unknown('unknown');

  const VoiceIntent(this.wire);

  final String wire;
}

/// The screens voice is allowed to open.
///
/// A closed enum rather than a route string: the agent's reply comes from a
/// model, and a model must never be able to name a URL directly.
///
/// Only screens that exist are listed, so the agent can never name a destination
/// the app would have to refuse. Reaching this list means "voice can open it".
enum VoiceDestination {
  diagnosis('diagnosis'),
  assistant('assistant'),
  cropAdvice('crop_advice'),
  weather('weather'),
  krishiBarta('krishi_barta'),
  haatBazar('haat_bazar'),
  orders('orders'),
  history('history'),
  profile('profile');

  const VoiceDestination(this.wire);

  final String wire;

  static VoiceDestination? fromWire(String? value) {
    if (value == null) return null;
    for (final d in VoiceDestination.values) {
      if (d.wire == value) return d;
    }
    return null;
  }
}

/// Where an answer came from. The farmer must be able to see that the app is
/// repeating a verified document rather than composing its own advice.
@immutable
class VoiceSource {
  const VoiceSource({required this.title, this.kbId});

  final String title;
  final String? kbId;

  factory VoiceSource.fromJson(Map<String, dynamic> json) => VoiceSource(
        title: json['title'] as String? ?? '',
        kbId: json['kb_id'] as String?,
      );
}

/// The answer to a spoken question (`POST /voice/ask`).
///
/// `found == false` is a first-class outcome, not an error: the knowledge base
/// is deliberately finite and the app says so out loud instead of letting a
/// model improvise a pesticide dose.
@immutable
class VoiceAnswer {
  const VoiceAnswer({
    required this.transcript,
    required this.found,
    required this.answerText,
    this.sources = const [],
    this.offerExpert = false,
  });

  final String transcript;
  final bool found;
  final String answerText;
  final List<VoiceSource> sources;

  /// True when the farmer should be offered the expert queue instead.
  final bool offerExpert;

  factory VoiceAnswer.fromJson(Map<String, dynamic> json) => VoiceAnswer(
        transcript: json['transcript'] as String? ?? '',
        found: json['found'] as bool? ?? false,
        answerText: json['answer_text'] as String? ?? '',
        sources: ((json['sources'] as List<dynamic>?) ?? const [])
            .map((e) => VoiceSource.fromJson(e as Map<String, dynamic>))
            .toList(),
        offerExpert: json['offer_expert'] as bool? ?? false,
      );
}

/// One interpreted command.
///
/// Everything the UI needs to *show before it acts* (FR-37) is here: the raw
/// transcript, how sure the agent is, and which action it chose.
@immutable
class VoiceCommand {
  const VoiceCommand({
    required this.intent,
    required this.transcript,
    required this.confidence,
    this.destination,
    this.query,
    this.category,
    this.quantity = 1,
    this.answer,
  });

  final VoiceIntent intent;

  /// What the recogniser heard, verbatim. Shown to the farmer so a
  /// mishearing is visible instead of mysterious.
  final String transcript;

  /// 0.0-1.0. Below [minConfidence] the app asks for a repeat and never acts —
  /// the same 0.70 floor the diagnosis flow uses for "do not present this as
  /// final". Pinned by `test/voice_command_test.dart`.
  final double confidence;

  final VoiceDestination? destination;

  /// Free-text search term, as the farmer said it.
  final String? query;

  /// Wire category for a product search (`fungicide`, `seed`…).
  final String? category;

  final int quantity;

  /// The grounded answer to an [VoiceIntent.ask] question.
  final String? answer;

  static const double minConfidence = 0.70;

  bool get isConfident => confidence >= minConfidence;

  /// True only when every piece of a money action is known. Anything less goes
  /// back to the farmer as a question.
  bool get canOrder => intent == VoiceIntent.orderProduct && category != null;

  static VoiceCommand unknown(String transcript, {double confidence = 0}) =>
      VoiceCommand(
        intent: VoiceIntent.unknown,
        transcript: transcript,
        confidence: confidence,
      );
}
