import '../models/voice.dart';
import '../repositories/voice_repository.dart';
import 'api_client.dart';

class RemoteVoiceRepository implements VoiceRepository {
  RemoteVoiceRepository(this._client);

  final ApiClient _client;

  @override
  Future<VoiceCommand> interpret(String transcript) async {
    final response = await _client.post(
      '/voice/interpret',
      body: {'transcript': transcript},
      auth: true,
    );

    final intentWire = response['intent'] as String? ?? 'unknown';
    final intent = VoiceIntent.values.firstWhere(
      (i) => i.wire == intentWire,
      orElse: () => VoiceIntent.unknown,
    );

    final destination =
        VoiceDestination.fromWire(response['destination'] as String?);
    final confidence = (response['confidence'] as num?)?.toDouble() ?? 0.0;
    final answer = response['answer'] as String?;

    return VoiceCommand(
      intent: intent,
      transcript: transcript,
      confidence: confidence,
      destination: destination,
      answer: answer,
    );
  }

  @override
  Future<VoiceAnswer> ask(String question) async {
    final response = await _client.post(
      '/voice/ask',
      body: {'query': question},
      auth: true,
    );

    return VoiceAnswer.fromJson(response);
  }
}
