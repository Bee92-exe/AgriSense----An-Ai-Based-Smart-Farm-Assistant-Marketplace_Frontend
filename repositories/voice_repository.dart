import '../models/voice.dart';

/// Turns what was heard into a command.
///
/// Phase 1 answers from the mock keyword agent; the real `/voice/command`
/// endpoint answers with the same shape, so no screen has to change when the
/// backend lands.
abstract interface class VoiceRepository {
  /// [transcript] is raw recogniser output, in Bangla or English.
  ///
  /// Implementations must not throw for "I did not understand" — that is a
  /// normal result ([VoiceIntent.unknown]) and the UI has a state for it.
  /// Throwing is reserved for a real failure (offline, server down), which the
  /// UI shows as the error state with a "use the buttons" escape hatch.
  Future<VoiceCommand> interpret(String transcript);

  /// `POST /voice/ask` — a question, answered from the verified knowledge base.
  ///
  /// Never invents an answer: when the base has nothing, [VoiceAnswer.found] is
  /// false and the assistant offers a human instead.
  Future<VoiceAnswer> ask(String question);
}
