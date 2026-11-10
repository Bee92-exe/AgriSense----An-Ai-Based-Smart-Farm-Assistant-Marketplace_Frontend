import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/settings_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/alpona.dart';
import '../../core/widgets/ambience.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/confidence_gauge.dart';
import '../../core/widgets/read_aloud.dart';
import '../../core/widgets/states.dart';
import '../../data/models/diagnosis.dart';
import '../../data/models/enums.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../home/home_providers.dart';

/// The result screen, in all three states the design system specifies.
///
/// The rule that drives this whole file: below 0.70 the app must **not** show a
/// disease name. [Diagnosis.canShowDisease] enforces it, so even a server that
/// wrongly sent `show_as_final: true` with a low score cannot get a name onto
/// this screen. Verified by `test/diagnosis_safety_test.dart`.
///
/// Visually it is built as a judgement slip: a painted margin down the left of
/// the verdict carries the confidence colour, so the answer's certainty is
/// legible at arm's length before a single word is read. The words, the icon and
/// the number are all still there — colour is never the only cue.
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.diagnosisId});

  final String? diagnosisId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);

    if (diagnosisId == null) {
      return AppScreen(
        title: l.diagnosisResultTitle,
        child: ErrorState(onRetry: () => context.pop()),
      );
    }

    final async = ref.watch(diagnosisByIdProvider(diagnosisId!));

    return AppScreen(
      title: l.diagnosisResultTitle,
      ambience: AmbienceMood.result,
      child: async.when(
        loading: () => const LoadingState(rows: 3),
        error: (_, _) => ErrorState(
          onRetry: () => ref.invalidate(diagnosisByIdProvider(diagnosisId!)),
        ),
        data: (d) => _Body(diagnosis: d),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.diagnosis});

  final Diagnosis diagnosis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final d = diagnosis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // A pending expert case is its own state: no gauge of the AI's
        // confidence, because that number is not what the farmer is waiting on.
        if (d.isPendingReview) _PendingReviewNote(diagnosis: d),

        if (d.canShowDisease)
          _Verdict(diagnosis: d)
        else if (!d.isPendingReview)
          _Uncertain(diagnosis: d),

        if (d.treatmentSteps != null && d.treatmentSteps!.isNotEmpty) ...[
          const SizedBox(height: Space.lg),
          Row(
            children: [
              Expanded(
                child: SectionHeader(
                  title: l.diagnosisTreatmentTitle,
                  icon: Icons.list_alt_rounded,
                ),
              ),
              // Reads the very steps on this card. Auto-plays when the farmer
              // has voice mode on — a farmer who cannot read the card should
              // not have to find a button to hear it either.
              ReadAloudButton(
                text: speechForSteps(
                  d.treatmentSteps!,
                  Localizations.localeOf(context).languageCode,
                ),
                tooltip: l.diagnosisReadAll,
                autoPlay: ref.watch(settingsProvider).voiceMode,
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          _StepsCard(steps: d.treatmentSteps!),
        ],

        if (d.top3.isNotEmpty && d.canShowDisease) ...[
          const SizedBox(height: Space.md),
          _Top3(diagnosis: d),
        ],

        const SizedBox(height: Space.lg),
        // Ordering medicine is only ever offered behind an answer the app is
        // willing to stand behind. On a low-confidence or pending case the way
        // forward is a better photo or an expert, not a purchase.
        if (d.canShowDisease)
          AppButton(
            label: l.diagnosisOrderMedicine,
            icon: Icons.storefront_rounded,
            onPressed: () => context.push(Routes.market),
          ),
        if (d.canShowDisease && d.confidenceLevel != ConfidenceLevel.high) ...[
          const SizedBox(height: Space.xs),
          AppButton(
            label: l.diagnosisSendToExpert,
            tone: AppButtonTone.secondary,
            icon: Icons.person_search_rounded,
            onPressed: () => _requestReview(context, ref),
          ),
        ],
        const SizedBox(height: Space.md),
        const DisclaimerNote(),
      ],
    );
  }

  Future<void> _requestReview(BuildContext context, WidgetRef ref) async {
    final l = AppL10n.of(context);
    try {
      await ref.read(diagnosisRepositoryProvider).requestReview(diagnosis.id);
      ref.invalidate(diagnosisByIdProvider(diagnosis.id));
      ref.invalidate(diagnosisHistoryProvider);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.diagnosisSentToExpert)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.stateErrorBody)),
      );
    }
  }
}

/// A card with a painted margin: a solid strip of the result's colour down the
/// left edge, then the content on rice paper.
class _MarginCard extends StatelessWidget {
  const _MarginCard({
    required this.accent,
    required this.child,
    this.tint,
  });

  final Color accent;
  final Color? tint;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: tint ?? p.surface,
        borderRadius: Radii.cardAll,
        border: Border.all(color: p.outline, width: p.borderWidth),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 8, color: accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(Space.md),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The answer, when there is one that may be shown.
class _Verdict extends StatelessWidget {
  const _Verdict({required this.diagnosis});

  final Diagnosis diagnosis;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final locale = Localizations.localeOf(context).languageCode;
    final d = diagnosis;
    final healthy = d.isHealthy;
    final accent = healthy ? p.success : _levelColour(p, d.confidenceLevel);

    return _MarginCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  [
                    if (d.crop != null) d.crop!.label(l),
                    AppFormat.of(context).relative(d.createdAt),
                  ].join(' · '),
                  style: context.texts.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const AiBadge(),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(
            d.disease!.label(locale),
            style: context.texts.displayLarge?.copyWith(
              fontSize: 28,
              height: 1.3,
            ),
          ),
          if (healthy) ...[
            const SizedBox(height: Space.xxs),
            Row(
              children: [
                Icon(Icons.check_circle_rounded, color: p.success, size: 20),
                const SizedBox(width: Space.xxs),
                Expanded(
                  child: Text(
                    l.diagnosisHealthyTitle,
                    style: context.texts.bodySmall
                        ?.copyWith(color: p.onSurface),
                  ),
                ),
              ],
            ),
          ],
          if (d.reviewedByExpert) ...[
            const SizedBox(height: Space.xs),
            Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: p.onPrimaryContainer,
                ),
                const SizedBox(width: Space.xxs),
                Text(
                  l.diagnosisExpertReviewed,
                  style: context.texts.labelSmall
                      ?.copyWith(color: p.onPrimaryContainer),
                ),
              ],
            ),
          ],
          const SizedBox(height: Space.md),
          Center(
            child: ConfidenceGauge(
              score: d.confidence,
              level: d.confidenceLevel,
              size: 190,
            ),
          ),
          if (d.confidenceLevel.needsCaution) ...[
            const SizedBox(height: Space.sm),
            _CautionRow(text: l.diagnosisMediumCaution),
          ],
        ],
      ),
    );
  }
}

/// The < 0.70 state: no disease name, an explanation, a retake, and the expert
/// path. It is not dressed as an error — nothing failed, the photo was simply
/// not enough to be sure — but it is unmistakably *not* an answer.
class _Uncertain extends ConsumerWidget {
  const _Uncertain({required this.diagnosis});

  final Diagnosis diagnosis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final p = context.palette;
    // `failed` is the server saying the photo held no crop leaf at all. That is
    // a different message from "I cannot tell which disease this is": there is
    // nothing to be unsure about, so the card says what to photograph instead.
    final notLeaf = diagnosis.failed;

    return _MarginCard(
      accent: p.warning,
      tint: p.harvestContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                notLeaf
                    ? Icons.image_not_supported_rounded
                    : Icons.help_outline_rounded,
                color: p.onHarvestContainer,
              ),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Text(
                  notLeaf
                      ? l.diagnosisNotLeafTitle
                      : l.diagnosisLowTitle,
                  style: context.texts.titleMedium
                      ?.copyWith(color: p.onHarvestContainer),
                ),
              ),
              const AiBadge(),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(
            notLeaf ? l.diagnosisNotLeafBody : l.diagnosisLowBody,
            style: context.texts.bodySmall
                ?.copyWith(color: p.onHarvestContainer),
          ),
          const SizedBox(height: Space.md),
          AppButton(
            label: l.diagnosisRetake,
            icon: Icons.photo_camera_rounded,
            onPressed: () => context.pushReplacement(Routes.capture),
          ),
          const SizedBox(height: Space.xs),
          AppButton(
            label: l.diagnosisSendToExpert,
            tone: AppButtonTone.secondary,
            icon: Icons.person_search_rounded,
            onPressed: () async {
              try {
                await ref
                    .read(diagnosisRepositoryProvider)
                    .requestReview(diagnosis.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.diagnosisSentToExpert)),
                );
              } catch (_) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.stateErrorBody)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PendingReviewNote extends StatelessWidget {
  const _PendingReviewNote({required this.diagnosis});

  final Diagnosis diagnosis;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.md),
      child: _MarginCard(
        accent: p.info,
        tint: p.info.withValues(alpha: 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.hourglass_top_rounded, color: p.info),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Text(
                    l.diagnosisLowTitle,
                    style: context.texts.titleMedium?.copyWith(color: p.info),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.xxs),
            Text(
              l.diagnosisLowBody,
              style: context.texts.bodySmall?.copyWith(color: p.onSurface),
            ),
            const SizedBox(height: Space.md),
            AppButton(
              label: l.diagnosisRetake,
              icon: Icons.photo_camera_rounded,
              onPressed: () => context.pushReplacement(Routes.capture),
            ),
          ],
        ),
      ),
    );
  }
}

class _CautionRow extends StatelessWidget {
  const _CautionRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(Space.sm),
      decoration: BoxDecoration(
        color: p.harvestContainer,
        borderRadius: Radii.fieldAll,
        border: Border.all(color: p.onHarvestContainer, width: p.borderWidth),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.help_rounded, size: 20, color: p.onHarvestContainer),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Text(
              text,
              style: context.texts.bodySmall
                  ?.copyWith(color: p.onHarvestContainer),
            ),
          ),
        ],
      ),
    );
  }
}

/// The treatment plan as one spoken paragraph.
///
/// The numbered steps read as a list would sound odd out loud, so each step is
/// prefixed with its number in the farmer's own digits, and the source lines are
/// left out — provenance is for the eye, not for the ear.
String speechForSteps(List<TreatmentStep> steps, String locale) => steps
    .map((step) => '${AppFormat(locale).number(step.order)}. ${step.label(locale)}')
    .join('. ');

/// The numbered treatment plan. Each step keeps its source line, because the
/// whole point of the knowledge base is that this advice has provenance.
class _StepsCard extends StatelessWidget {
  const _StepsCard({required this.steps});

  final List<TreatmentStep> steps;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final locale = Localizations.localeOf(context).languageCode;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Space.sm),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: p.outline.withValues(alpha: 0.25),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Medallion(
                  icon: Icons.check_rounded,
                  size: 34,
                  background: p.primaryContainer,
                  foreground: p.onPrimaryContainer,
                  child: Text(
                    AppFormat.of(context).number(steps[i].order),
                    style: context.texts.labelSmall?.copyWith(
                      color: p.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        steps[i].label(locale),
                        style: context.texts.bodyMedium,
                      ),
                      if (steps[i].source != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          steps[i].source!,
                          style: context.texts.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: Space.md),
          const StitchDivider(),
          const SizedBox(height: Space.sm),
          // Safety text is not optional on a screen that may lead to a
          // pesticide purchase.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.health_and_safety_rounded,
                color: p.warning,
                size: 20,
              ),
              const SizedBox(width: Space.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.diagnosisSafetyTitle, style: context.texts.labelSmall),
                    Text(
                      l.diagnosisSafetyBody,
                      style: context.texts.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The runner-up guesses. Shown only when the top answer is being presented as
/// final — otherwise it would leak a disease name for a low-confidence case.
class _Top3 extends StatelessWidget {
  const _Top3({required this.diagnosis});

  final Diagnosis diagnosis;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final locale = Localizations.localeOf(context).languageCode;
    final f = AppFormat.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.diagnosisShowTop3, style: context.texts.titleSmall),
          const SizedBox(height: Space.sm),
          for (final (disease, score) in diagnosis.top3)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          disease.label(locale),
                          style: context.texts.bodySmall
                              ?.copyWith(color: p.onSurface),
                        ),
                      ),
                      Text(
                        f.percentFromFraction(score),
                        style: context.texts.labelSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: Radii.chipAll,
                    child: LinearProgressIndicator(
                      value: score.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: p.surfaceSunken,
                      color: p.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

Color _levelColour(AppPalette p, ConfidenceLevel level) => switch (level) {
      ConfidenceLevel.high => p.confidenceHigh,
      ConfidenceLevel.medium => p.confidenceMedium,
      ConfidenceLevel.low => p.confidenceLow,
    };
