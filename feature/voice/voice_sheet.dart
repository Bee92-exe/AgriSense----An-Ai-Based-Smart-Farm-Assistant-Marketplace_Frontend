import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/voice/speaker.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/voice.dart';
import '../../l10n/app_localizations.dart';
import 'voice_controller.dart';

/// The route a spoken command means, or null when this build has no such screen.
///
/// Total on purpose: a new [VoiceDestination] must be given a route here rather
/// than silently doing nothing.
String? routeForVoiceDestination(VoiceDestination destination) =>
    switch (destination) {
      VoiceDestination.diagnosis => Routes.capture,
      VoiceDestination.assistant => Routes.assistant,
      VoiceDestination.cropAdvice => Routes.cropAdvice,
      VoiceDestination.weather => Routes.weather,
      VoiceDestination.krishiBarta => Routes.news,
      VoiceDestination.haatBazar => Routes.market,
      VoiceDestination.orders => Routes.orders,
      VoiceDestination.history => Routes.history,
      VoiceDestination.profile => Routes.profile,
    };

/// Opens the voice sheet.
///
/// Navigation happens *here*, after the sheet has closed, so a spoken command
/// never leaves a modal hanging over the screen it opened.
Future<void> showVoiceSheet(BuildContext context) async {
  final destination = await showModalBottomSheet<VoiceDestination>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const VoiceSheet(),
  );
  if (destination == null || !context.mounted) return;
  final route = routeForVoiceDestination(destination);
  if (route != null) context.go(route);
}

/// The voice sheet: one state of `VOICE_UX.md` §2 at a time.
///
/// Every state that can be reached by speaking can also be reached by tapping —
/// the typed field and the option buttons exist so the sheet is usable on a
/// device with no microphone, and so no farmer is ever trapped in a modal they
/// cannot talk their way out of.
class VoiceSheet extends ConsumerStatefulWidget {
  const VoiceSheet({super.key});

  @override
  ConsumerState<VoiceSheet> createState() => _VoiceSheetState();
}

class _VoiceSheetState extends ConsumerState<VoiceSheet> {
  final _typed = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Opening the sheet is the farmer saying "I want to talk", so listening
    // starts immediately rather than behind a second tap.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(voiceControllerProvider.notifier).start();
    });
  }

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  void _say(String text) {
    if (text.trim().isEmpty) return;
    ref.read(speakerProvider).speak(
          text,
          languageCode: Localizations.localeOf(context).languageCode,
        );
  }

  /// Leaves a beat between the spoken confirmation and the screen changing, so
  /// the farmer hears what happened before the sheet disappears.
  Future<void> _closeAfterSpeaking(VoiceDestination? destination) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pop(destination);
  }

  /// The farmer asked for the touch path: stop listening *and* stop talking, so
  /// a command cannot still be carried out after the sheet has gone.
  void _stopAndClose() {
    ref.read(speakerProvider).stop();
    unawaited(ref.read(voiceControllerProvider.notifier).cancel());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final state = ref.watch(voiceControllerProvider);

    ref.listen<VoiceState>(voiceControllerProvider, (_, next) {
      switch (next) {
        case VoiceUnderstood():
          _say(_spokenFor(next, l));
          if (next.destination != null) {
            _closeAfterSpeaking(next.destination);
          }
        case VoiceConfirming():
          _say(_confirmSpoken(next, l));
        case VoicePlaced():
          _say(l.orderPlaced);
        case VoiceClarifying():
          _say(l.voiceCouldNotUnderstand);
        case VoiceFailed():
          _say(_failureText(next, l));
        case VoiceListening():
        case VoiceProcessing():
        case VoicePlacing():
        case VoiceIdle():
          break;
      }
    });

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, Space.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  state is VoiceFailed
                      ? Icons.mic_off_rounded
                      : Icons.graphic_eq_rounded,
                  color: state is VoiceFailed ? p.onSurfaceMuted : p.aiAccent,
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    _titleFor(state, l),
                    style: context.texts.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.md),
            ..._bodyFor(state, l),
          ],
        ),
      ),
    );
  }

  String _titleFor(VoiceState state, AppL10n l) => switch (state) {
        VoiceIdle() => l.voiceMicLabel,
        VoiceListening() => l.voiceListening,
        VoiceProcessing() || VoiceUnderstood() || VoicePlacing() =>
          l.voiceProcessing,
        VoiceConfirming() => l.voiceConfirmationTitle,
        VoicePlaced() => l.orderPlaced,
        VoiceClarifying() => l.voiceCouldNotUnderstand,
        VoiceFailed() => l.stateErrorTitle,
      };


  List<Widget> _bodyFor(VoiceState state, AppL10n l) => switch (state) {
        VoiceIdle() => [
            const Center(child: CircularProgressIndicator()),
          ],
        VoiceListening(:final level, :final heard) => [
            LinearProgressIndicator(
              value: (level / 10).clamp(0.05, 1),
              minHeight: 6,
            ),
            if (heard != null && heard.trim().isNotEmpty) ...[
              const SizedBox(height: Space.sm),
              Text(l.voiceUnderstood(heard), style: context.texts.bodyMedium),
            ],
            const SizedBox(height: Space.md),
            _typedField(l),
            const SizedBox(height: Space.sm),
            AppButton(
              label: l.voiceCancel,
              tone: AppButtonTone.secondary,
              icon: Icons.close_rounded,
              onPressed: _stopAndClose,
            ),
          ],
        VoiceProcessing(:final heard) => [
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: Space.sm),
            Text(l.voiceUnderstood(heard), style: context.texts.bodyMedium),
            const SizedBox(height: Space.sm),
            AppButton(
              label: l.voiceCancel,
              tone: AppButtonTone.secondary,
              icon: Icons.close_rounded,
              onPressed: _stopAndClose,
            ),
          ],
        VoiceUnderstood() => _understood(state, l),
        VoiceConfirming() => _confirming(state, l),
        VoicePlacing() => [
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: Space.sm),
            Text(l.voiceProcessing, style: context.texts.bodyMedium),
          ],
        VoicePlaced(:final orderNo) => [
            Row(
              children: [
                const Icon(Icons.check_circle_rounded),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Text(orderNo, style: context.texts.titleSmall),
                ),
              ],
            ),
            const SizedBox(height: Space.md),
            AppButton(
              label: l.actionClose,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        VoiceClarifying(:final heard, :final choices) => [
            if (heard.isNotEmpty)
              Text(l.voiceUnderstood(heard), style: context.texts.bodyMedium),
            Text(l.voiceAskAgain, style: context.texts.bodySmall),
            const SizedBox(height: Space.sm),
            for (final choice in choices) ...[
              AppButton(
                label: _labelFor(choice.labelKey, l),
                tone: AppButtonTone.secondary,
                onPressed: () =>
                    ref.read(voiceControllerProvider.notifier).runChoice(
                          choice.command,
                        ),
              ),
              const SizedBox(height: Space.xs),
            ],
            const SizedBox(height: Space.xs),
            _typedField(l),
            const SizedBox(height: Space.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l.voiceAskAgain,
                    icon: Icons.mic_rounded,
                    onPressed: () =>
                        ref.read(voiceControllerProvider.notifier).start(),
                  ),
                ),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: AppButton(
                    label: l.voiceUseTouch,
                    tone: AppButtonTone.secondary,
                    onPressed: _stopAndClose,
                  ),
                ),
              ],
            ),
          ],
        VoiceFailed(:final detail) => [
            Text(
              detail ?? _failureText(state, l),
              style: context.texts.bodyMedium,
            ),
            const SizedBox(height: Space.md),
            _typedField(l),
            const SizedBox(height: Space.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l.actionRetry,
                    icon: Icons.mic_rounded,
                    onPressed: () =>
                        ref.read(voiceControllerProvider.notifier).start(),
                  ),
                ),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: AppButton(
                    label: l.voiceUseTouch,
                    tone: AppButtonTone.secondary,
                    onPressed: _stopAndClose,
                  ),
                ),
              ],
            ),
          ],
      };

  List<Widget> _understood(VoiceUnderstood state, AppL10n l) => [
        Text(state.command.transcript, style: context.texts.bodyMedium),
        const SizedBox(height: Space.sm),
        AppCard(
          tint: context.palette.surfaceSunken,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final line in _replyLines(state, l)) ...[
                Text(line, style: context.texts.bodyMedium),
                const SizedBox(height: Space.xxs),
              ],
              if (state.answer != null) ...[
                Text(l.voiceAnswerTitle, style: context.texts.labelSmall),
                const SizedBox(height: Space.xxs),
                Text(state.answer!, style: context.texts.bodySmall),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.md),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: l.actionClose,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: Space.xs),
            Expanded(
              child: AppButton(
                label: l.voiceUseTouch,
                tone: AppButtonTone.secondary,
                onPressed: _stopAndClose,
              ),
            ),
          ],
        ),
      ];

  List<Widget> _confirming(VoiceConfirming state, AppL10n l) {
    final f = AppFormat.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final total = state.product.price * state.quantity;

    return [
      Text(l.voiceConfirmationBody, style: context.texts.bodySmall),
      const SizedBox(height: Space.sm),
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(state.product.label(locale), style: context.texts.titleSmall),
            Text(
              state.product.vendor.shopName,
              style: context.texts.bodySmall,
            ),
            const Divider(),
            Row(
              children: [
                Text(
                  '${l.selectQuantity}: ${f.number(state.quantity)}',
                  style: context.texts.bodyMedium,
                ),
                const Spacer(),
                Text(f.taka(total), style: context.texts.titleSmall),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: Space.md),
      // The one place a voice command may create an order — and only after this
      // button is actually pressed. The label says what the press does rather
      // than "confirm", because this is the last screen before money moves.
      AppButton(
        label: l.voiceConfirmYes,
        icon: Icons.check_rounded,
        onPressed: () => ref.read(voiceControllerProvider.notifier).confirm(),
      ),
      const SizedBox(height: Space.xs),
      AppButton(
        label: l.actionCancel,
        tone: AppButtonTone.secondary,
        onPressed: () {
          ref.read(voiceControllerProvider.notifier).decline();
          Navigator.of(context).pop();
        },
      ),
    ];
  }

  Widget _typedField(AppL10n l) => TextField(
        controller: _typed,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(hintText: l.voiceTypeInstead),
        onSubmitted: (value) =>
            ref.read(voiceControllerProvider.notifier).submitText(value),
      );

  String _labelFor(String key, AppL10n l) => switch (key) {
        'navMarket' => l.navMarket,
        'homeTileWeather' => l.homeTileWeather,
        'homeScanAction' => l.homeScanAction,
        'categoryFungicide' => l.categoryFungicide,
        'categorySeed' => l.categorySeed,
        'categoryFertilizer' => l.categoryFertilizer,
        _ => l.actionNext,
      };

  String _screenLabel(VoiceDestination? destination, AppL10n l) =>
      switch (destination) {
        VoiceDestination.diagnosis => l.navDiagnosis,
        VoiceDestination.assistant => l.assistantTitle,
        VoiceDestination.cropAdvice => l.adviceTitle,
        VoiceDestination.weather => l.weatherTitle,
        VoiceDestination.krishiBarta => l.navNews,
        VoiceDestination.haatBazar => l.navMarket,
        VoiceDestination.orders => l.navOrders,
        VoiceDestination.history => l.navHistory,
        VoiceDestination.profile => l.navProfile,
        null => l.navHome,
      };

  /// What the sheet shows for a command it is about to carry out.
  List<String> _replyLines(VoiceUnderstood state, AppL10n l) {
    final f = AppFormat.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    if (state.products.isNotEmpty) {
      return [
        l.voiceFound(
          state.command.query ?? state.command.transcript,
          f.number(state.products.length),
        ),
        for (final product in state.products.take(3))
          l.voicePriceLine(product.label(locale), f.taka(product.price)),
      ];
    }
    if (state.answer != null) return const [];
    if (state.destination != null) {
      return [l.voiceOpening(_screenLabel(state.destination, l))];
    }
    return const [];
  }

  /// The same lines, as one breath for the speaker.
  String _spokenFor(VoiceUnderstood state, AppL10n l) {
    final f = AppFormat.of(context);
    if (state.answer != null) return state.answer!;
    if (state.weather != null) {
      final w = state.weather!;
      return l.voiceWeatherSummary(
        w.district,
        f.number(w.current.tempC.round()),
        w.current.condition,
      );
    }
    return _replyLines(state, l).join('. ');
  }

  String _confirmSpoken(VoiceConfirming state, AppL10n l) {
    final f = AppFormat.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    return l.voicePlaceOrder(
      state.product.label(locale),
      f.number(state.quantity),
    );
  }

  String _failureText(VoiceFailed state, AppL10n l) =>
      state.detail ??
      (state.reason == VoiceFailure.noMicrophone
          ? l.voiceNoSpeech
          : l.stateErrorBody);
}
