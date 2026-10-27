import 'package:agrisense/data/mock/mock_repositories.dart';
import 'package:agrisense/data/models/voice.dart';
import 'package:flutter_test/flutter_test.dart';

/// The Phase 1 keyword agent stands in for `/voice/command`, so its mapping is
/// the whole contract between the sheet and the AI service that replaces it.
///
/// The cases that matter most are the ones that keep a farmer safe: a product
/// word plus an order word must never be read as a search, and anything the
/// agent is not sure about must come back under the 0.70 floor so the sheet asks
/// instead of acting.
void main() {
  final agent = MockVoiceRepository(config: MockConfig());

  Future<VoiceCommand> ask(String text) => agent.interpret(text);

  test('Bangla navigation phrase opens the marketplace', () async {
    final command = await ask('বাজারে যাও');
    expect(command.intent, VoiceIntent.navigate);
    expect(command.destination, VoiceDestination.haatBazar);
    expect(command.isConfident, isTrue);
  });

  test('English navigation phrase is understood too', () async {
    final command = await ask('go to history');
    expect(command.intent, VoiceIntent.navigate);
    expect(command.destination, VoiceDestination.history);
  });

  test('a weather question reads as a weather request', () async {
    final command = await ask('আজকের আবহাওয়া কেমন?');
    expect(command.intent, VoiceIntent.weather);
    expect(command.destination, VoiceDestination.weather);
  });

  test('a product word with "দেখাও" is a search, not a purchase', () async {
    final command = await ask('ছত্রাকনাশক দেখাও');
    expect(command.intent, VoiceIntent.searchProduct);
    expect(command.category, 'fungicide');
    expect(command.isConfident, isTrue);
  });

  test('an order phrase wins over the product word in it', () async {
    final command = await ask('দুই বোতল ছত্রাকনাশক অর্ডার করো');
    expect(command.intent, VoiceIntent.orderProduct);
    expect(command.category, 'fungicide');
    expect(command.quantity, 2);
  });

  test('an order with no product named asks instead of guessing', () async {
    final command = await ask('এইটা অর্ডার করো');
    expect(command.intent, VoiceIntent.orderProduct);
    expect(command.category, isNull);
    // Below the acting floor: the sheet must ask which product.
    expect(command.isConfident, isFalse);
  });

  test('a question is answered, never treated as a command', () async {
    final command = await ask('ধানে পাতা পোড়া রোগে কী করব?');
    expect(command.intent, VoiceIntent.ask);
    expect(command.answer, isNotNull);
    // The demo answer must not invent a pesticide or a dose (knowledge.md).
    expect(command.answer, contains('ডেমো'));
    expect(command.answer, isNot(contains('গ্রাম')));
  });

  test('silence and nonsense come back as unknown, without throwing', () async {
    final empty = await ask('');
    expect(empty.intent, VoiceIntent.unknown);
    expect(empty.confidence, 0);

    final nonsense = await ask('আকাশে তারা ভাসছে');
    expect(nonsense.intent, VoiceIntent.unknown);
    expect(nonsense.isConfident, isFalse);
  });

  test('one weak keyword is heard but not acted on', () async {
    final command = await ask('বাজার');
    expect(command.confidence, lessThan(VoiceCommand.minConfidence));
  });
}
