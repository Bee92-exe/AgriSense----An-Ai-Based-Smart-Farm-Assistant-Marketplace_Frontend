import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/voice/speech_recognizer.dart';
import '../../data/models/enums.dart';
import '../../data/models/product.dart';
import '../../data/models/voice.dart';
import '../../data/models/weather.dart';
import '../../data/providers.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/market_repository.dart';
import '../market/market_screen.dart';

/// The states of `VOICE_UX.md` §2, as types.
///
/// Sealed, so the sheet cannot forget a state when it renders: adding one here
/// breaks the switch in `voice_sheet.dart` at compile time.
sealed class VoiceState {
  const VoiceState();
}

class VoiceIdle extends VoiceState {
  const VoiceIdle();
}

class VoiceListening extends VoiceState {
  const VoiceListening({this.level = 0, this.heard});

  /// 0-10, straight from the recogniser.
  final double level;

  /// Partial transcript, shown while the farmer is still speaking.
  final String? heard;
}

class VoiceProcessing extends VoiceState {
  const VoiceProcessing(this.heard);

  final String heard;
}

/// The command was understood. The sheet shows and speaks it, then acts.
class VoiceUnderstood extends VoiceState {
  const VoiceUnderstood({
    required this.command,
    this.destination,
    this.products = const [],
    this.weather,
    this.answer,
  });

  final VoiceCommand command;

  /// Set when the action is to open a screen.
  final VoiceDestination? destination;

  /// Search results, so the reply can name the top few with prices.
  final List<Product> products;

  final WeatherReport? weather;

  /// The grounded answer to a question.
  final String? answer;
}

/// A money action, waiting for an explicit yes.
class VoiceConfirming extends VoiceState {
  const VoiceConfirming({
    required this.product,
    required this.quantity,
    required this.command,
  });

  final Product product;
  final int quantity;
  final VoiceCommand command;
}

class VoicePlacing extends VoiceState {
  const VoicePlacing();
}

class VoicePlaced extends VoiceState {
  const VoicePlaced(this.orderNo);

  final String orderNo;
}

/// Nothing usable was heard, or the agent was not sure enough to act.
///
/// Never a dead end: [choices] are tappable commands, so the farmer can carry on
/// by touch from inside the sheet.
class VoiceClarifying extends VoiceState {
  const VoiceClarifying({required this.heard, required this.choices});

  final String heard;
  final List<VoiceChoice> choices;
}

/// Why voice stopped. Localised by the sheet, which is the only layer that has
/// a `BuildContext`.
enum VoiceFailure {
  /// No microphone, no permission, or no speech service on this device.
  noMicrophone,

  /// Anything else: offline, server error, a bug.
  unavailable,
}

/// A real failure (offline, server down, no microphone on this device).
class VoiceFailed extends VoiceState {
  const VoiceFailed(this.reason, {this.detail, this.heard});

  final VoiceFailure reason;

  /// Server wording, when the failure came back from one. Shown in preference
  /// to the generic sentence because the server knows why it refused.
  final String? detail;

  final String? heard;
}

/// One tappable option shown while clarifying.
@immutable
class VoiceChoice {
  const VoiceChoice({required this.labelKey, required this.command});

  /// ARB key; the sheet localises it.
  final String labelKey;
  final VoiceCommand command;
}

/// One recogniser session, wired to the mock agent for now.
///
/// The controller owns *what happened*; the sheet owns *what it looks like and
/// what is said*. That split keeps this class free of Flutter widgets, l10n and
/// the TTS plugin, so the whole state machine is unit-testable.
class VoiceController extends Notifier<VoiceState> {
  Timer? _safety;
  bool _busy = false;

  /// The longest a session may stay open, matching the recogniser's own limit.
  static const Duration listeningWindow = Duration(seconds: 15);

  @override
  VoiceState build() {
    // Captured now: Riverpod forbids touching `ref` inside a dispose callback,
    // and the recogniser must still be released when the sheet's provider goes
    // away with a session open.
    final recognizer = ref.read(speechRecognizerProvider);
    ref.onDispose(() {
      _safety?.cancel();
      unawaited(recognizer.cancel());
    });
    return const VoiceIdle();
  }

  Future<void> start() async {
    if (_busy) return;
    _busy = true;
    try {
      final recognizer = ref.read(speechRecognizerProvider);
      final ready = await recognizer.prepare();
      if (!ready) {
        state = const VoiceFailed(VoiceFailure.noMicrophone);
        return;
      }
      state = const VoiceListening();
      await recognizer.start(
        listenFor: listeningWindow,
        onHeard: (heard) {
          if (state is! VoiceListening) return;
          state = VoiceListening(level: 0, heard: heard.text);
          if (heard.isFinal && heard.text.trim().isNotEmpty) {
            unawaited(_interpret(heard.text));
          }
        },
        onLevel: (level) {
          final current = state;
          if (current is VoiceListening) {
            state = VoiceListening(
              level: level.clamp(0, 10),
              heard: current.heard,
            );
          }
        },
        onDone: () {
          // The recogniser stopped without a usable phrase.
          final current = state;
          if (current is VoiceListening) {
            state = VoiceClarifying(
              heard: current.heard?.trim() ?? '',
              choices: _fallbackChoices(),
            );
          }
        },
      );
      // A plugin that never reports back (seen on web when the microphone is
      // blocked) must not leave the sheet spinning forever.
      _safety?.cancel();
      _safety = Timer(listeningWindow + const Duration(seconds: 2), () {
        if (state is VoiceListening) {
          state = VoiceClarifying(heard: '', choices: _fallbackChoices());
        }
      });
    } finally {
      _busy = false;
    }
  }

  /// The typed path: same start-to-finish flow, no microphone.
  ///
  /// Every voice action has to work without voice (PRD), and this is also what
  /// keeps the sheet usable on a machine with no microphone at all.
  Future<void> submitText(String text) async {
    if (text.trim().isEmpty) {
      state = VoiceClarifying(heard: '', choices: _fallbackChoices());
      return;
    }
    await _interpret(text);
  }

  /// Re-runs a choice the farmer tapped while clarifying.
  Future<void> runChoice(VoiceCommand command) => _execute(command);

  Future<void> cancel() async {
    _safety?.cancel();
    await ref.read(speechRecognizerProvider).cancel();
    state = const VoiceIdle();
  }

  void reset() {
    _safety?.cancel();
    state = const VoiceIdle();
  }

  /// The explicit yes in the money flow. Nothing else creates an order.
  Future<void> confirm() async {
    final current = state;
    if (current is! VoiceConfirming) return;
    state = const VoicePlacing();
    try {
      final order = await ref.read(marketRepositoryProvider).placeOrder(
            PlaceOrderRequest(
              // A per-attempt id, so a retry after a dropped connection cannot
              // create a second order for the same confirmation.
              clientUuid: const Uuid().v4(),
              items: <({String productId, int quantity})>[
                (productId: current.product.id, quantity: current.quantity),
              ],
              paymentMode: 'cod',
              placedVia: InputMode.voice,
            ),
          );
      state = VoicePlaced(order.orderNo);
    } catch (e) {
      state = VoiceFailed(
        VoiceFailure.unavailable,
        detail: _detailOf(e),
        heard: current.command.transcript,
      );
    }
  }

  /// The no. Must leave no order behind — `test/voice_flow_test.dart` asserts it.
  void decline() {
    state = const VoiceIdle();
  }

  Future<void> _interpret(String transcript) async {
    _safety?.cancel();
    state = VoiceProcessing(transcript);
    final VoiceCommand command;
    try {
      command = await ref.read(voiceRepositoryProvider).interpret(transcript);
    } catch (e) {
      state = VoiceFailed(
        VoiceFailure.unavailable,
        detail: _detailOf(e),
        heard: transcript,
      );
      return;
    }

    if (!command.isConfident || command.intent == VoiceIntent.unknown) {
      // Heard the words, not the intent: offer options instead of guessing.
      state = VoiceClarifying(
        heard: transcript,
        choices: _choicesFor(command),
      );
      return;
    }
    await _execute(command);
  }

  Future<void> _execute(VoiceCommand command) async {
    if (state is! VoiceProcessing) state = VoiceProcessing(command.transcript);
    try {
      switch (command.intent) {
        case VoiceIntent.navigate:
          state = VoiceUnderstood(
            command: command,
            destination: command.destination,
          );

        case VoiceIntent.weather:
          final report = await ref.read(weatherRepositoryProvider).report();
          state = VoiceUnderstood(
            command: command,
            destination: VoiceDestination.weather,
            weather: report,
          );

        case VoiceIntent.searchProduct:
          // The filter is set before navigating, so the farmer lands on the
          // products they asked for rather than on an empty search box.
          final filter = ref.read(marketFilterProvider.notifier);
          if (command.category != null) {
            filter.setCategory(command.category);
          } else {
            filter.setText(command.query ?? command.transcript);
          }
          final found = await ref.read(marketRepositoryProvider).products(
                query: ProductQuery(
                  category: command.category,
                  text: command.category == null ? command.query : null,
                  inStockOnly: true,
                ),
              );
          state = VoiceUnderstood(
            command: command,
            // With no match there is nowhere useful to go, so the sheet stays
            // open and offers alternatives.
            destination: found.isEmpty ? null : VoiceDestination.haatBazar,
            products: found,
          );

        case VoiceIntent.orderProduct:
          await _prepareOrder(command);

        case VoiceIntent.ask:
          state = VoiceUnderstood(command: command, answer: command.answer);

        case VoiceIntent.unknown:
          state = VoiceClarifying(
            heard: command.transcript,
            choices: _fallbackChoices(),
          );
      }
    } catch (e) {
      state = VoiceFailed(
        VoiceFailure.unavailable,
        detail: _detailOf(e),
        heard: command.transcript,
      );
    }
  }

  /// Resolves *which* product before asking for money.
  ///
  /// When several products match, the cheapest in-stock one is proposed and the
  /// confirmation sheet names it: the farmer's yes is the disambiguation step,
  /// which is the only place ambiguity may be resolved for a purchase.
  Future<void> _prepareOrder(VoiceCommand command) async {
    if (command.category == null) {
      state = VoiceClarifying(
        heard: command.transcript,
        choices: _orderChoices(),
      );
      return;
    }
    final candidates = await ref.read(marketRepositoryProvider).products(
          query: ProductQuery(category: command.category, inStockOnly: true),
        );
    if (candidates.isEmpty) {
      state = VoiceClarifying(
        heard: command.transcript,
        choices: _orderChoices(except: command.category),
      );
      return;
    }
    final product = candidates.reduce((a, b) => a.price <= b.price ? a : b);
    state = VoiceConfirming(
      product: product,
      quantity: command.quantity.clamp(1, max(1, product.stock)),
      command: command,
    );
  }

  /// Tappable alternatives while clarifying, each a complete command so a tap
  /// and a spoken phrase take the same path ([_execute]).
  List<VoiceChoice> _choicesFor(VoiceCommand command) =>
      command.category == null ? _fallbackChoices() : _orderChoices();

  List<VoiceChoice> _orderChoices({String? except}) {
    const categories = [
      ('fungicide', 'categoryFungicide'),
      ('seed', 'categorySeed'),
      ('fertilizer', 'categoryFertilizer'),
    ];
    return [
      for (final (wire, labelKey) in categories)
        if (wire != except)
          VoiceChoice(
            labelKey: labelKey,
            command: VoiceCommand(
              intent: VoiceIntent.orderProduct,
              transcript: '',
              confidence: 1,
              category: wire,
            ),
          ),
    ];
  }

  /// What to offer when nothing was understood: the three most useful screens,
  /// never a menu of everything.
  List<VoiceChoice> _fallbackChoices() => const [
        VoiceChoice(
          labelKey: 'navMarket',
          command: VoiceCommand(
            intent: VoiceIntent.navigate,
            transcript: '',
            confidence: 1,
            destination: VoiceDestination.haatBazar,
          ),
        ),
        VoiceChoice(
          labelKey: 'homeTileWeather',
          command: VoiceCommand(
            intent: VoiceIntent.weather,
            transcript: '',
            confidence: 1,
            destination: VoiceDestination.weather,
          ),
        ),
        VoiceChoice(
          labelKey: 'homeScanAction',
          command: VoiceCommand(
            intent: VoiceIntent.navigate,
            transcript: '',
            confidence: 1,
            destination: VoiceDestination.diagnosis,
          ),
        ),
      ];

  /// The server's own wording when it sent one; otherwise null and the sheet
  /// falls back to its generic sentence.
  String? _detailOf(Object error) {
    if (error is! ApiException) return null;
    return error.serverMessageBn ?? error.serverMessageEn;
  }
}

final speechRecognizerProvider = Provider<SpeechRecognizer>(
  (ref) => DeviceSpeechRecognizer(),
);

final voiceControllerProvider =
    NotifierProvider<VoiceController, VoiceState>(VoiceController.new);
