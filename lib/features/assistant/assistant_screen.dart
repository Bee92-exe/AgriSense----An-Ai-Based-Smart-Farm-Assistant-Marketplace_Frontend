import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/settings_provider.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/voice/speaker.dart';
import '../../core/widgets/ambience.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/mic_fab.dart';
import '../../core/widgets/read_aloud.dart';
import '../../core/widgets/states.dart';
import '../../data/models/voice.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shell/farmer_shell.dart';
import '../voice/voice_controller.dart';

/// One question and its answer, kept for the session.
class AssistantTurn {
  const AssistantTurn({required this.question, required this.answer});

  final String question;
  final VoiceAnswer answer;
}

/// Where the assistant is in the ask → answer cycle.
sealed class AssistantState {
  const AssistantState();
}

class AssistantIdle extends AssistantState {
  const AssistantIdle();
}

class AssistantListening extends AssistantState {
  const AssistantListening({this.heard});

  final String? heard;
}

class AssistantThinking extends AssistantState {
  const AssistantThinking(this.question);

  final String question;
}

/// A question is answered by the verified knowledge base, or honestly refused.
class AssistantAnswered extends AssistantState {
  const AssistantAnswered(this.answer);

  final VoiceAnswer answer;
}

class AssistantFailed extends AssistantState {
  const AssistantFailed(this.detail);

  final String? detail;
}

class AssistantController extends Notifier<AssistantState> {
  @override
  AssistantState build() => const AssistantIdle();

  Future<void> startListening() async {
    final recognizer = ref.read(speechRecognizerProvider);
    final ready = await recognizer.prepare();
    if (!ready) {
      state = const AssistantFailed(null);
      return;
    }
    state = const AssistantListening();
    await recognizer.start(
      onHeard: (heard) {
        if (state is! AssistantListening) return;
        state = AssistantListening(heard: heard.text);
        if (heard.isFinal && heard.text.trim().isNotEmpty) {
          unawaited(ask(heard.text));
        }
      },
      onLevel: (_) {},
      onDone: () {
        if (state is AssistantListening) state = const AssistantIdle();
      },
    );
  }

  /// The typed path and the spoken path end in the same call, so both exercise
  /// the same repository and the same answer states.
  Future<void> ask(String question) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return;
    state = AssistantThinking(trimmed);
    try {
      final answer = await ref.read(voiceRepositoryProvider).ask(trimmed);
      state = AssistantAnswered(answer);
      ref.read(assistantHistoryProvider.notifier).add(
            AssistantTurn(question: trimmed, answer: answer),
          );
    } catch (_) {
      state = const AssistantFailed(null);
    }
  }

  Future<void> cancel() async {
    await ref.read(speechRecognizerProvider).cancel();
    state = const AssistantIdle();
  }
}

final assistantProvider =
    NotifierProvider<AssistantController, AssistantState>(
  AssistantController.new,
);

/// Session history. `GET /voice/logs` exists on the server, but the screen asks
/// for "recent Q&A", so this is the list built while the app is open rather than
/// a new endpoint invented for it.
class AssistantHistory extends Notifier<List<AssistantTurn>> {
  @override
  List<AssistantTurn> build() => const [];

  void add(AssistantTurn turn) => state = [turn, ...state].take(10).toList();
}

final assistantHistoryProvider =
    NotifierProvider<AssistantHistory, List<AssistantTurn>>(
  AssistantHistory.new,
);

/// The voice assistant: ask a question, get a sourced answer or an honest "I do
/// not know" (FR-10..12).
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final state = ref.watch(assistantProvider);

    // Answers are spoken only when the farmer turned voice mode on; otherwise
    // the play button is the way to hear one (design system §8).
    ref.listen<AssistantState>(assistantProvider, (_, next) {
      if (next is! AssistantAnswered) return;
      if (!ref.read(settingsProvider).voiceMode) return;
      if (next.answer.found) {
        _say(next.answer.answerText);
      }
    });

    return AppScreen(
      title: l.assistantTitle,
      ambience: AmbienceMood.field,
      bottomNav: const FarmerNav(current: FarmerTab.home),
      fab: const FarmerMicFab(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.assistantIntro, style: context.texts.bodyMedium),
          const SizedBox(height: Space.md),
          _AskPanel(
            state: state,
            typed: _typed,
            onListen: () => ref.read(assistantProvider.notifier).startListening(),
            onStop: () => ref.read(assistantProvider.notifier).cancel(),
            onSubmit: () {
              final text = _typed.text;
              _typed.clear();
              ref.read(assistantProvider.notifier).ask(text);
            },
          ),
          const SizedBox(height: Space.md),
          switch (state) {
            AssistantIdle() => const SizedBox.shrink(),
            AssistantListening(:final heard) => _ListeningCard(heard: heard),
            AssistantThinking(:final question) =>
              _ThinkingCard(question: question),
            AssistantAnswered(:final answer) => _AnswerCard(answer: answer),
            AssistantFailed(:final detail) => ErrorState(
                body: detail,
                onRetry: () => ref.read(assistantProvider.notifier).ask(
                      _typed.text.isEmpty ? l.assistantAsk : _typed.text,
                    ),
              ),
          },
          const SizedBox(height: Space.lg),
          const _HistorySection(),
        ],
      ),
    );
  }

  void _say(String text) {
    ref.read(speakerProvider).speak(
          text,
          languageCode: Localizations.localeOf(context).languageCode,
        );
  }
}

/// The big mic plus the typed alternative. Both routes are always visible: a
/// farmer who cannot speak, or whose phone has no microphone, must not be stuck.
class _AskPanel extends StatelessWidget {
  const _AskPanel({
    required this.state,
    required this.typed,
    required this.onListen,
    required this.onStop,
    required this.onSubmit,
  });

  final AssistantState state;
  final TextEditingController typed;
  final VoidCallback onListen;
  final VoidCallback onStop;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final listening = state is AssistantListening;

    return AppCard(
      tint: context.palette.surfaceSunken,
      child: Column(
        children: [
          Center(
            child: MicFab(
              isEnabled: true,
              isListening: listening,
              onPressed: listening ? onStop : onListen,
            ),
          ),
          const SizedBox(height: Space.xs),
          Text(
            listening ? l.assistantListening : l.assistantMicHint,
            style: context.texts.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Space.sm),
          TextField(
            controller: typed,
            textInputAction: TextInputAction.send,
            decoration: InputDecoration(
              hintText: l.assistantAsk,
              prefixIcon: const Icon(Icons.edit_rounded),
            ),
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: Space.sm),
          AppButton(
            label: l.assistantAsk,
            icon: Icons.send_rounded,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _ListeningCard extends StatelessWidget {
  const _ListeningCard({required this.heard});

  final String? heard;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return AppCard(
      child: Row(
        children: [
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Text(
              heard == null || heard!.trim().isEmpty
                  ? l.assistantListening
                  : l.voiceUnderstood(heard!),
              style: context.texts.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingCard extends StatelessWidget {
  const _ThinkingCard({required this.question});

  final String question;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.assistantYouAsked(question), style: context.texts.bodySmall),
          const SizedBox(height: Space.sm),
          Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(width: Space.sm),
              Text(l.assistantThinking, style: context.texts.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

/// The answer, or the refusal. Both carry the AI badge: one is generated from a
/// verified document, the other is the app declining to guess.
class _AnswerCard extends ConsumerWidget {
  const _AnswerCard({required this.answer});

  final VoiceAnswer answer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.assistantYouAsked(answer.transcript),
                  style: context.texts.bodySmall
                      ?.copyWith(color: p.onSurfaceMuted),
                ),
              ),
              const AiBadge(),
            ],
          ),
          const SizedBox(height: Space.sm),
          if (answer.found) ...[
            Text(
              answer.answerText,
              style: context.texts.bodyMedium?.copyWith(height: 1.7),
            ),
            if (answer.sources.isNotEmpty) ...[
              const SizedBox(height: Space.sm),
              Text(l.assistantSources, style: context.texts.labelSmall),
              const SizedBox(height: Space.xxs),
              Wrap(
                spacing: Space.xs,
                runSpacing: Space.xxs,
                children: [
                  for (final source in answer.sources)
                    Chip(
                      avatar: const Icon(Icons.menu_book_rounded, size: 18),
                      label: Text(source.title),
                    ),
                ],
              ),
            ],
            const SizedBox(height: Space.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: ReadAloudButton(
                text: answer.answerText,
                label: l.actionReadAloud,
              ),
            ),
          ] else ...[
            Text(l.assistantNoAnswerTitle, style: context.texts.titleSmall),
            const SizedBox(height: Space.xxs),
            Text(l.assistantNoAnswerBody, style: context.texts.bodySmall),
            const SizedBox(height: Space.sm),
            AppButton(
              label: l.assistantOfferExpert,
              tone: AppButtonTone.secondary,
              icon: Icons.person_search_rounded,
              // Sending a free-text question to an expert needs a backend
              // endpoint that does not exist yet, so the button says so instead
              // of pretending the question was delivered.
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                showDragHandle: true,
                builder: (sheetContext) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.md,
                    0,
                    Space.md,
                    Space.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.assistantOfferExpert,
                        style: context.texts.titleMedium,
                      ),
                      const SizedBox(height: Space.xs),
                      Text(
                        l.comingSoonBody,
                        textAlign: TextAlign.center,
                        style: context.texts.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistorySection extends ConsumerWidget {
  const _HistorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final history = ref.watch(assistantHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l.assistantHistoryTitle,
          icon: Icons.history_rounded,
        ),
        const SizedBox(height: Space.xs),
        if (history.isEmpty)
          Text(l.assistantHistoryEmpty, style: context.texts.bodySmall)
        else
          for (final turn in history) ...[
            ListRow(
              leading: Icon(
                turn.answer.found
                    ? Icons.check_circle_rounded
                    : Icons.help_rounded,
                color: turn.answer.found
                    ? context.palette.severityLow
                    : context.palette.warning,
              ),
              title: turn.question,
              subtitle: turn.answer.found
                  ? turn.answer.answerText
                  : l.assistantNoAnswerTitle,
            ),
            const SizedBox(height: Space.xxs),
          ],
      ],
    );
  }
}
