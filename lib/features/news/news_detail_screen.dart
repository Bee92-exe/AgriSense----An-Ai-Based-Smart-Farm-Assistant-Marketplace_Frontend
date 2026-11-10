import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/settings_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/read_aloud.dart';
import '../../core/widgets/states.dart';
import '../../data/models/news_item.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

final _newsItemProvider =
    FutureProvider.family<NewsItem, String>((ref, id) async {
  return ref.watch(newsRepositoryProvider).detail(id);
});

/// The words a farmer hears when this item is read aloud: the same title,
/// summary and advised action that are on the screen, in that order.
///
/// The advised action only has a Bangla source field (the news pipeline stores
/// what the SAAO wrote), so it is only read out in Bangla rather than read out
/// in the wrong language.
String speechForNews(NewsItem item, String locale) => [
      item.title(locale),
      item.summary(locale),
      if (locale == 'bn' && (item.advisedActionBn?.isNotEmpty ?? false))
        item.advisedActionBn!,
      if (locale == 'bn' && (item.symptomsBn?.isNotEmpty ?? false))
        item.symptomsBn!,
    ].join('. ');

/// One published item, with its source and verifier always visible.
///
/// The published gate is a server rule, but the screen still states who verified
/// the item and where it came from, because "an expert approved this" is the
/// reason a farmer should trust it over a rumour.
class NewsDetailScreen extends ConsumerWidget {
  const NewsDetailScreen({super.key, required this.newsId});

  final String newsId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final async = ref.watch(_newsItemProvider(newsId));
    final item = async.value;

    return AppScreen(
      title: l.navNews,
      // Appears only once the item is loaded, so the button can never read out
      // an empty page. Read-aloud is a control, not a placeholder: it used to
      // open a "coming soon" snackbar.
      actions: [
        if (item != null)
          ReadAloudButton(
            text: speechForNews(
              item,
              Localizations.localeOf(context).languageCode,
            ),
            autoPlay: ref.watch(settingsProvider).voiceMode,
          ),
      ],
      child: async.when(
        loading: () => const LoadingState(rows: 3),
        error: (_, _) => ErrorState(
          onRetry: () => ref.invalidate(_newsItemProvider(newsId)),
        ),
        data: (item) => _Body(item: item),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final f = AppFormat.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SeverityChip(severity: item.severity),
            const SizedBox(width: Space.xs),
            if (item.crop != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Space.xs,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: p.surfaceSunken,
                  borderRadius: Radii.chipAll,
                  border: Border.all(color: p.outline, width: p.borderWidth),
                ),
                child: Text(
                  item.crop!.label(l),
                  style: context.texts.labelSmall,
                ),
              ),
          ],
        ),
        const SizedBox(height: Space.sm),
        Text(item.title(locale), style: context.texts.titleLarge),
        const SizedBox(height: Space.xs),
        Text(
          '${item.source.name} · ${f.longDate(item.publishedAt)}',
          style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
        ),
        const SizedBox(height: Space.md),

        AppCard(
          child: Text(item.summary(locale), style: context.texts.bodyLarge),
        ),

        if (item.symptomsBn != null && item.symptomsBn!.isNotEmpty) ...[
          const SizedBox(height: Space.lg),
          SectionHeader(title: l.diagnosisResultTitle, icon: Icons.search_rounded),
          const SizedBox(height: Space.xs),
          AppCard(child: Text(item.symptomsBn!, style: context.texts.bodyMedium)),
        ],

        if (item.advisedActionBn != null && item.advisedActionBn!.isNotEmpty) ...[
          const SizedBox(height: Space.lg),
          SectionHeader(title: l.diagnosisTreatmentTitle, icon: Icons.list_alt_rounded),
          const SizedBox(height: Space.xs),
          AppCard(
            tint: p.primaryContainer,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.task_alt_rounded, color: p.onPrimaryContainer),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Text(
                    item.advisedActionBn!,
                    style: context.texts.bodyMedium
                        ?.copyWith(color: p.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (item.affectedDistricts.isNotEmpty) ...[
          const SizedBox(height: Space.lg),
          SectionHeader(
            title: l.consentLocationTitle,
            icon: Icons.place_outlined,
          ),
          const SizedBox(height: Space.xs),
          AppCard(
            child: Wrap(
              spacing: Space.xs,
              runSpacing: Space.xs,
              children: [
                for (final d in item.affectedDistricts)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Space.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: p.surfaceSunken,
                      borderRadius: Radii.chipAll,
                      border:
                          Border.all(color: p.outline, width: p.borderWidth),
                    ),
                    child: Text(d, style: context.texts.labelSmall),
                  ),
              ],
            ),
          ),
        ],

        const SizedBox(height: Space.lg),
        if (item.verifiedBy != null)
          AppCard(
            tint: p.surfaceSunken,
            child: Row(
              children: [
                Icon(Icons.verified_rounded, color: p.primary),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.diagnosisExpertReviewed,
                          style: context.texts.labelSmall),
                      Text(
                        item.verifiedBy!,
                        style: context.texts.bodySmall
                            ?.copyWith(color: p.onSurfaceMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: Space.lg),
        OutlinedButton.icon(
          onPressed: () => context.push(Routes.capture),
          icon: const Icon(Icons.center_focus_strong_rounded),
          label: Text(l.homeTileCheckCrop),
        ),
        const SizedBox(height: Space.xs),
        OutlinedButton.icon(
          onPressed: () => context.push(Routes.market),
          icon: const Icon(Icons.storefront_rounded),
          label: Text(l.homeTileMarket),
        ),
        const SizedBox(height: Space.md),
        DisclaimerNote(),
      ],
    );
  }
}
