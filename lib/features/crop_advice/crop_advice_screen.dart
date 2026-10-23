import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/session_provider.dart';
import '../../core/router/app_router.dart';
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
import '../../core/widgets/states.dart';
import '../../data/models/crop.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shell/farmer_shell.dart';

/// What the farmer has told the form so far. Held in a provider so returning
/// from the calendar does not reset the picks.
class AdviceSelection {
  const AdviceSelection({
    this.soilType,
    this.season,
    this.district,
    this.seasonChosenManually = false,
    this.seasonChosen = false,
    this.districtChosen = false,
  });

  final String? soilType;
  final String? season;
  final String? district;

  /// True once the farmer picked a season themselves, so the calendar's
  /// suggestion stops overriding them.
  final bool seasonChosenManually;
  final bool seasonChosen;
  final bool districtChosen;

  /// The season the calendar suggests for [month].
  String suggestedSeason(int month) => Seasons.forMonth(month);

  AdviceSelection copyWith({
    String? soilType,
    String? season,
    String? district,
    bool? seasonChosenManually,
    bool? seasonChosen,
    bool? districtChosen,
  }) =>
      AdviceSelection(
        soilType: soilType ?? this.soilType,
        season: season ?? this.season,
        district: district ?? this.district,
        seasonChosenManually: seasonChosenManually ?? this.seasonChosenManually,
        seasonChosen: seasonChosen ?? this.seasonChosen,
        districtChosen: districtChosen ?? this.districtChosen,
      );
}

class AdviceSelectionNotifier extends Notifier<AdviceSelection> {
  @override
  AdviceSelection build() {
    final user = ref.watch(currentUserProvider);
    return AdviceSelection(
      season: Seasons.forMonth(DateTime.now().month),
      district: user?.district,
    );
  }

  void pickSoil(String soil) => state = state.copyWith(soilType: soil);

  void pickSeason(String season) => state = state.copyWith(
        season: season,
        seasonChosen: true,
        seasonChosenManually: true,
      );

  void pickDistrict(String district) =>
      state = state.copyWith(district: district, districtChosen: true);

  void useSuggestedSeason(String season) => state = state.copyWith(
        season: season,
        seasonChosenManually: false,
      );
}

final adviceSelectionProvider =
    NotifierProvider<AdviceSelectionNotifier, AdviceSelection>(
  AdviceSelectionNotifier.new,
);

/// The answer for the current picks. `data == null` means the farmer has not
/// asked yet — the screen shows the form, not a spinner.
class AdviceController extends Notifier<AsyncValue<CropAdvice?>> {
  @override
  AsyncValue<CropAdvice?> build() => const AsyncData(null);

  Future<void> submit() async {
    final selection = ref.read(adviceSelectionProvider);
    final soil = selection.soilType;
    final season = selection.season;
    final district = selection.district;
    if (soil == null || season == null || district == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cropRepositoryProvider).recommend(
            district: district,
            soilType: soil,
            season: season,
          ),
    );
    // The saved list is part of the answer: a fresh recommendation is now in it.
    ref.invalidate(savedAdviceProvider);
  }
}

final adviceProvider =
    NotifierProvider<AdviceController, AsyncValue<CropAdvice?>>(
  AdviceController.new,
);

final savedAdviceProvider = FutureProvider<List<CropAdvice>>(
  (ref) => ref.watch(cropRepositoryProvider).savedRecommendations(),
);

final soilTypesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(cropRepositoryProvider).soilTypes(),
);

final adviceDistrictsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(cropRepositoryProvider).districts(),
);

/// Crop advice (FR-13).
///
/// Three inputs, then three crops with a reason each. The screen never shows a
/// ranked name without its reason, and it always says whether the district's
/// weather was part of the ranking — a recommendation that ignored the forecast
/// is a different, weaker claim.
class CropAdviceScreen extends ConsumerWidget {
  const CropAdviceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final selection = ref.watch(adviceSelectionProvider);
    final advice = ref.watch(adviceProvider);

    return AppScreen(
      title: l.adviceTitle,
      ambience: AmbienceMood.field,
      bottomNav: const FarmerNav(current: FarmerTab.home),
      fab: const FarmerMicFab(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.adviceIntro, style: context.texts.bodyMedium),
          const SizedBox(height: Space.md),
          _SoilPicker(selection: selection),
          const SizedBox(height: Space.md),
          _SeasonPicker(selection: selection),
          const SizedBox(height: Space.md),
          _DistrictPicker(selection: selection),
          const SizedBox(height: Space.md),
          AppButton(
            label: l.adviceAction,
            icon: Icons.auto_awesome_rounded,
            isLoading: advice.isLoading,
            // Nothing to recommend from until a soil is known; the button says
            // so by being disabled rather than failing after a round trip.
            isEnabled: selection.soilType != null,
            onPressed: () => ref.read(adviceProvider.notifier).submit(),
          ),
          const SizedBox(height: Space.lg),
          advice.when(
            loading: () => const LoadingState(rows: 3, showHeader: false),
            error: (_, _) => ErrorState(
              onRetry: () => ref.read(adviceProvider.notifier).submit(),
            ),
            data: (result) => result == null
                ? const SizedBox.shrink()
                : _Results(advice: result),
          ),
          const SizedBox(height: Space.lg),
          const _SavedAdvice(),
        ],
      ),
    );
  }
}

/// Soil choice, one icon per type as the design system asks ("pick soil type
/// (icons)").
class _SoilPicker extends ConsumerWidget {
  const _SoilPicker({required this.selection});

  final AdviceSelection selection;

  static const Map<String, IconData> _icons = {
    'এঁটেল মাটি': Icons.water_rounded,
    'দোআঁশ মাটি': Icons.grass_rounded,
    'বেলে দোআঁশ': Icons.grain_rounded,
    'পলি মাটি': Icons.waves_rounded,
    'বালি মাটি': Icons.landscape_rounded,
    'অম্লীয় মাটি': Icons.science_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final soils = ref.watch(soilTypesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l.adviceSoil, icon: Icons.terrain_rounded),
        const SizedBox(height: Space.xs),
        soils.when(
          loading: () => const LoadingState(rows: 1, showHeader: false),
          error: (_, _) => ErrorState(
            onRetry: () => ref.invalidate(soilTypesProvider),
          ),
          data: (list) => Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final soil in list)
                ChoiceChip(
                  avatar: Icon(_icons[soil] ?? Icons.eco_rounded, size: 20),
                  label: Text(soil),
                  selected: selection.soilType == soil,
                  onSelected: (_) => ref
                      .read(adviceSelectionProvider.notifier)
                      .pickSoil(soil),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Season, pre-filled from the calendar and overridable.
class _SeasonPicker extends ConsumerWidget {
  const _SeasonPicker({required this.selection});

  final AdviceSelection selection;

  static const Map<String, IconData> _icons = {
    Seasons.rabi: Icons.ac_unit_rounded,
    Seasons.kharif1: Icons.wb_twilight_rounded,
    Seasons.kharif2: Icons.water_drop_rounded,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final suggested = selection.suggestedSeason(DateTime.now().month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l.adviceSeason, icon: Icons.event_rounded),
        const SizedBox(height: Space.xs),
        Wrap(
          spacing: Space.xs,
          runSpacing: Space.xs,
          children: [
            for (final season in Seasons.all)
              ChoiceChip(
                avatar: Icon(_icons[season] ?? Icons.eco_rounded, size: 20),
                label: Text(season),
                selected: selection.season == season,
                onSelected: (_) => ref
                    .read(adviceSelectionProvider.notifier)
                    .pickSeason(season),
              ),
          ],
        ),
        const SizedBox(height: Space.xxs),
        // Says where the pre-selection came from, and offers the way back to it
        // after the farmer has overridden it by hand.
        Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 16, color: p.onSurfaceMuted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${l.adviceSeasonAuto}: $suggested',
                style: context.texts.bodySmall
                    ?.copyWith(color: p.onSurfaceMuted),
              ),
            ),
            if (selection.seasonChosenManually && selection.season != suggested)
              TextButton(
                onPressed: () => ref
                    .read(adviceSelectionProvider.notifier)
                    .useSuggestedSeason(suggested),
                child: Text(suggested),
              ),
          ],
        ),
      ],
    );
  }
}

class _DistrictPicker extends ConsumerWidget {
  const _DistrictPicker({required this.selection});

  final AdviceSelection selection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final districts = ref.watch(adviceDistrictsProvider);

    // The farmer's own district stands in until the list arrives, so the form is
    // never blank on a slow connection.
    final items = districts.value ?? [if (selection.district != null) selection.district!];

    return DropdownButtonFormField<String>(
      initialValue: selection.district,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l.adviceDistrict,
        prefixIcon: const Icon(Icons.place_outlined),
      ),
      items: [
        for (final district in items)
          DropdownMenuItem(value: district, child: Text(district)),
      ],
      onChanged: (v) {
        if (v != null) {
          ref.read(adviceSelectionProvider.notifier).pickDistrict(v);
        }
      },
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.advice});

  final CropAdvice advice;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l.adviceResultsTitle,
          icon: Icons.eco_rounded,
        ),
        const SizedBox(height: Space.xxs),
        _WeatherNote(included: advice.weatherIncluded),
        const SizedBox(height: Space.xs),
        for (final result in advice.results) ...[
          _RecommendationCard(result: result),
          const SizedBox(height: Space.xs),
        ],
        const SizedBox(height: Space.xs),
        AppButton(
          label: l.adviceCalendar,
          tone: AppButtonTone.secondary,
          icon: Icons.calendar_month_rounded,
          onPressed: () => context.push(
            '${Routes.calendar}/${advice.results.first.crop.wire}',
          ),
        ),
        const SizedBox(height: Space.xxs),
        Text(
          '${advice.district} · ${advice.soilType} · ${advice.season} · '
          '${f.shortDate(advice.createdAt)}',
          style: context.texts.bodySmall,
        ),
        const SizedBox(height: Space.xxs),
        // The AI badge and the disclaimer are not decoration: this is a model
        // output, and the design system forbids presenting one as a guarantee.
        const Align(alignment: Alignment.centerLeft, child: AiBadge()),
        const SizedBox(height: Space.xxs),
        // Its own wording: the shared note says "not a final diagnosis", which
        // is the wrong sentence on a screen that recommends crops.
        DisclaimerNote(text: l.adviceDisclaimer),
      ],
    );
  }
}

class _WeatherNote extends StatelessWidget {
  const _WeatherNote({required this.included});

  final bool included;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final colour = included ? p.severityLow : p.warning;

    return Semantics(
      label: included ? l.adviceWeatherIncluded : l.adviceWeatherMissing,
      child: Row(
        children: [
          Icon(
            included
                ? Icons.cloud_done_rounded
                : Icons.cloud_off_rounded,
            size: 18,
            color: colour,
          ),
          const SizedBox(width: Space.xxs),
          Expanded(
            child: Text(
              included ? l.adviceWeatherIncluded : l.adviceWeatherMissing,
              style: context.texts.bodySmall?.copyWith(color: colour),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.result});

  final CropRecommendation result;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final f = AppFormat.of(context);

    return AppCard(
      onTap: () =>
          context.push('${Routes.calendar}/${result.crop.wire}'),
      semanticLabel: '${result.crop.label(l)}. ${result.reasonBn}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Medallion(
                icon: Icons.emoji_events_rounded,
                size: Sizes.medallion,
                background: p.primaryContainer,
                foreground: p.onPrimaryContainer,
                child: Text(
                  f.number(result.rank),
                  style: context.texts.labelSmall?.copyWith(
                    color: p.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Text(
                  result.crop.label(l),
                  style: context.texts.titleSmall,
                ),
              ),
              Text(
                f.percentFromFraction(result.score),
                style: context.texts.labelSmall
                    ?.copyWith(color: p.onSurfaceMuted),
              ),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(result.reasonBn, style: context.texts.bodySmall),
          const SizedBox(height: Space.xxs),
          Text(
            l.adviceCalendar,
            style: context.texts.bodySmall?.copyWith(color: p.primary),
          ),
        ],
      ),
    );
  }
}

class _SavedAdvice extends ConsumerWidget {
  const _SavedAdvice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final saved = ref.watch(savedAdviceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l.adviceSavedTitle,
          icon: Icons.bookmark_border_rounded,
        ),
        const SizedBox(height: Space.xs),
        saved.when(
          loading: () => const LoadingState(rows: 1, showHeader: false),
          error: (_, _) => ErrorState(
            onRetry: () => ref.invalidate(savedAdviceProvider),
          ),
          data: (list) => list.isEmpty
              ? Text(l.adviceSavedEmpty, style: context.texts.bodySmall)
              : Column(
                  children: [
                    for (final advice in list)
                      ListRow(
                        leading: const Icon(Icons.eco_rounded),
                        title: [
                          for (final r in advice.results.take(3))
                            r.crop.label(l),
                        ].join(' · '),
                        subtitle:
                            '${advice.district} · ${advice.soilType} · ${advice.season}',
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
