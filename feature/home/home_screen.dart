import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/session_provider.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/sky.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/alpona.dart';
import '../../core/widgets/ambience.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/big_action_tile.dart';
import '../../core/widgets/living_field.dart';
import '../../core/widgets/states.dart';
import '../../data/models/diagnosis.dart';
import '../../data/models/news_item.dart';
import '../../data/models/weather.dart';
import '../../l10n/app_localizations.dart';
import '../../shell/farmer_shell.dart';
import 'home_providers.dart';

/// The farmer's home: a living field, then a rice-paper sheet over it.
///
/// The hero is the app's only view of the outside world — its sky follows the
/// real weather and clock (see [skyFor]) and its crop line is what the sheet
/// below slides over. Everything under the sheet is plain and scannable: an
/// urgent alert if there is one, the six actions, then the photos already taken.
///
/// The six tiles are all live destinations. A tile that opens a "coming soon"
/// sheet is a dead end for a first-time user, and the design system forbids
/// decorative affordances.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();

  /// Fed to the hero's painter instead of rebuilding the page on every scroll
  /// frame: the parallax repaints one [RepaintBoundary], not the whole tree.
  final _offset = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => _offset.value = _scroll.offset);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _offset.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(settingsProvider);
    final weather = ref.watch(homeWeatherProvider);
    final news = ref.watch(homeNewsProvider);
    final diagnoses = ref.watch(diagnosisHistoryProvider);

    final now = weather.value?.current;
    final sky = skyFor(
      now: DateTime.now(),
      iconCode: now?.iconCode,
      highContrast: settings.highContrast,
    );

    final greetingName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name
        : l.defaultUserName;

    return Scaffold(
      backgroundColor: p.background,
      bottomNavigationBar: const FarmerNav(current: FarmerTab.home),
      floatingActionButton: const FarmerMicFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeWeatherProvider);
          ref.invalidate(homeNewsProvider);
          ref.invalidate(diagnosisHistoryProvider);
          await ref.read(homeWeatherProvider.future);
        },
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            SliverToBoxAdapter(
              child: LivingField(
                sky: sky,
                animated: settings.animatedMode,
                scrollOffset: _offset,
                child: _Hero(
                  greetingName: greetingName,
                  weather: weather,
                  sky: sky,
                  animated: settings.animatedMode,
                  highContrast: settings.highContrast,
                  onToggleAnimated: () => ref
                      .read(settingsProvider.notifier)
                      .setAnimatedMode(!settings.animatedMode),
                  onToggleContrast: () => ref
                      .read(settingsProvider.notifier)
                      .setHighContrast(!settings.highContrast),
                  onScan: () => context.push(Routes.capture),
                  onWeather: () => context.push(Routes.weather),
                  onRetryWeather: () => ref.invalidate(homeWeatherProvider),
                ),
              ),
            ),

            // The sheet rides up over the crop line. A negative-paint offset
            // rather than a drag handle: a handle would promise a drag gesture
            // this page does not have.
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -Space.lg),
                child: PageReveal(
                  child: Container(
                  decoration: BoxDecoration(
                    color: p.background,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    Space.md,
                    Space.md,
                    Space.md,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      news.maybeWhen(
                        data: (items) {
                          final urgent =
                              items.where((n) => n.isUrgent).toList();
                          if (urgent.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: Space.md),
                            child: _UrgentBanner(
                              item: urgent.first,
                              onTap: () =>
                                  context.push('/news/${urgent.first.id}'),
                            ),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),
                      SectionHeader(
                        title: l.homeSubtitle,
                        icon: Icons.grid_view_rounded,
                      ),
                      const SizedBox(height: Space.sm),
                      _ActionGrid(
                        newsCount:
                            news.value?.where((n) => !n.isRead).length ?? 0,
                      ),
                      const SizedBox(height: Space.md),
                      SectionHeader(
                        title: l.diagnosisHistoryTitle,
                        actionLabel: l.actionSeeAll,
                        onAction: () => context.push(Routes.history),
                      ),
                      const SizedBox(height: Space.xs),
                      diagnoses.when(
                        loading: () =>
                            const LoadingState(rows: 2, showHeader: false),
                        error: (_, _) => ErrorState(
                          onRetry: () =>
                              ref.invalidate(diagnosisHistoryProvider),
                        ),
                        data: (items) => items.isEmpty
                            ? _RecentEmptyCard(
                                onScan: () => context.push(Routes.capture),
                              )
                            : _RecentStrip(
                                items: items.take(6).toList(),
                                onOpen: (d) => context
                                    .push('${Routes.result}?id=${d.id}'),
                                onSeeAll: () => context.push(Routes.history),
                              ),
                      ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // The mic is docked on the nav bar's top edge and sits 60dp into
            // the page, so the list ends above it. Without this the last photo
            // card was permanently half behind the microphone.
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }
}

/// The content that lives on the sky itself.
class _Hero extends StatelessWidget {
  const _Hero({
    required this.greetingName,
    required this.weather,
    required this.sky,
    required this.animated,
    required this.highContrast,
    required this.onToggleAnimated,
    required this.onToggleContrast,
    required this.onScan,
    required this.onWeather,
    required this.onRetryWeather,
  });

  final String greetingName;
  final AsyncValue<WeatherReport> weather;
  final SkyGradient sky;
  final bool animated;
  final bool highContrast;
  final VoidCallback onToggleAnimated;
  final VoidCallback onToggleContrast;
  final VoidCallback onScan;
  final VoidCallback onWeather;
  final VoidCallback onRetryWeather;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Space.md, Space.xs, Space.md, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Medallion(
                  icon: Icons.eco_rounded,
                  size: Sizes.avatar,
                  background: sky.ink.withValues(alpha: 0.92),
                  foreground: sky.flat,
                ),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Text(
                    l.homeGreeting(greetingName),
                    style: context.texts.titleSmall
                        ?.copyWith(color: sky.ink, height: 1.3),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _SkyToggle(
                  icon: Icons.auto_awesome_rounded,
                  active: animated,
                  sky: sky,
                  tooltip: animated ? l.homeAnimationOn : l.homeAnimationOff,
                  onTap: onToggleAnimated,
                ),
                _SkyToggle(
                  icon: highContrast
                      ? Icons.light_mode_rounded
                      : Icons.light_mode_outlined,
                  active: highContrast,
                  sky: sky,
                  tooltip: l.homeContrastToggle,
                  onTap: onToggleContrast,
                ),
              ],
            ),
            const SizedBox(height: Space.xs),
            Text(
              l.homeFieldPrompt,
              style: context.texts.titleLarge
                  ?.copyWith(color: sky.ink, height: 1.35),
            ),
            Text(
              l.homeFieldPromptHint,
              style: context.texts.bodySmall
                  ?.copyWith(color: sky.ink.withValues(alpha: 0.85)),
            ),
            const SizedBox(height: Space.md),
            _SkyWeather(
              weather: weather,
              sky: sky,
              onOpen: onWeather,
              onRetry: onRetryWeather,
            ),
            const SizedBox(height: Space.sm),
            AnimatedSheen(
              enabled: animated,
              child: _BandAction(
                label: l.homeScanAction,
                icon: Icons.center_focus_strong_rounded,
                onTap: onScan,
              ),
            ),
            const SizedBox(height: Space.sm),
          ],
        ),
      ),
    );
  }
}

class _SkyWeather extends StatelessWidget {
  const _SkyWeather({
    required this.weather,
    required this.sky,
    required this.onOpen,
    required this.onRetry,
  });

  final AsyncValue<WeatherReport> weather;
  final SkyGradient sky;
  final VoidCallback onOpen;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);

    return weather.when(
      loading: () => _pill(
        context,
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: sky.ink,
              ),
            ),
            const SizedBox(width: Space.xs),
            Flexible(
              child: Text(
                l.stateLoading,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.texts.bodySmall?.copyWith(color: sky.ink),
              ),
            ),
          ],
        ),
      ),
      error: (_, _) => _pill(
        context,
        onTap: onRetry,
        child: Row(
          children: [
            Icon(Icons.cloud_off_rounded, size: 18, color: sky.ink),
            const SizedBox(width: Space.xs),
            Expanded(
              child: Text(
                l.homeWeatherUnavailable,
                style: context.texts.bodySmall?.copyWith(color: sky.ink),
              ),
            ),
            Icon(Icons.refresh_rounded, size: 18, color: sky.ink),
          ],
        ),
      ),
      data: (report) {
        final now = report.current;
        final alert = report.alerts.isEmpty ? null : report.alerts.first;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: onOpen,
              borderRadius: Radii.cardAll,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${f.number(now.tempC, decimals: 0)}°',
                    style: context.texts.displayLarge?.copyWith(
                      color: sky.ink,
                      fontSize: 52,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          now.condition,
                          style: context.texts.titleSmall
                              ?.copyWith(color: sky.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          report.district,
                          style: context.texts.bodySmall?.copyWith(
                            color: sky.ink.withValues(alpha: 0.82),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: sky.ink),
                  const SizedBox(width: Space.xxs),
                ],
              ),
            ),
            const SizedBox(height: Space.xs),
            // A Wrap, not a Row: at 320dp with 1.3x Bangla the two pills are
            // wider than the panel and the second one used to be clipped.
            Wrap(
              spacing: Space.xs,
              runSpacing: Space.xxs,
              children: [
                _pill(
                  context,
                  child: Text(
                    '${l.weatherHumidity} ${now.humidity}%',
                    style: context.texts.bodySmall?.copyWith(color: sky.ink),
                  ),
                ),
                _pill(
                  context,
                  child: Text(
                    '${l.weatherWind} '
                    '${f.number(now.windKph, decimals: 0)}',
                    style: context.texts.bodySmall?.copyWith(color: sky.ink),
                  ),
                ),
              ],
            ),
            if (alert != null) ...[
              const SizedBox(height: Space.xs),
              Container(
                padding: const EdgeInsets.all(Space.sm),
                decoration: BoxDecoration(
                  color: context.palette.harvestContainer,
                  borderRadius: Radii.fieldAll,
                  border: Border.all(
                    color: context.palette.onHarvestContainer,
                    width: context.palette.borderWidth,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: context.palette.onHarvestContainer,
                    ),
                    const SizedBox(width: Space.xs),
                    Expanded(
                      child: Text(
                        alert.messageBn,
                        style: context.texts.bodySmall?.copyWith(
                          color: context.palette.onHarvestContainer,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  /// A translucent chip. The tint is the sky's own ink at low alpha, so the
  /// pills sit *in* the sky instead of on it, and their text keeps the sky's
  /// contrast guarantee.
  Widget _pill(
    BuildContext context, {
    required Widget child,
    VoidCallback? onTap,
  }) {
    final content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.sm,
        vertical: Space.xxs + 2,
      ),
      decoration: BoxDecoration(
        color: sky.ink.withValues(alpha: 0.14),
        borderRadius: Radii.chipAll,
        border: Border.all(color: sky.ink.withValues(alpha: 0.28)),
      ),
      child: child,
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.chipAll,
      child: content,
    );
  }
}

/// The hero's small round toggles.
class _SkyToggle extends StatelessWidget {
  const _SkyToggle({
    required this.icon,
    required this.active,
    required this.sky,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final SkyGradient sky;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Semantics(
      button: true,
      toggled: active,
      label: tooltip,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        icon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? sky.ink.withValues(alpha: 0.22) : Colors.transparent,
            border: Border.all(
              color: sky.ink.withValues(alpha: active ? 0.85 : 0.35),
              width: active ? p.borderWidth + 1 : p.borderWidth,
            ),
          ),
          child: Icon(icon, size: 20, color: sky.ink),
        ),
      ),
    );
  }
}

/// The band's own button: harvest fill, ink label, stadium shape.
///
/// The sky is the only surface that inverts the page, so it needs its own action
/// treatment; every other primary action in the app is the indigo one.
class _BandAction extends StatelessWidget {
  const _BandAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: p.harvest,
        shape: StadiumBorder(
          side: BorderSide(color: p.onHarvest, width: p.borderWidth),
        ),
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: SizedBox(
            height: Sizes.secondaryButtonHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: Sizes.iconInline, color: p.onHarvest),
                const SizedBox(width: Space.xs),
                Text(
                  label,
                  style: context.texts.labelLarge?.copyWith(
                    color: p.onHarvest,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.newsCount});

  final int newsCount;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    // Two columns, fixed order. The tint index matches the tile's position so
    // the colour map never shuffles between launches.
    final tiles = <Widget>[
      BigActionTile(
        icon: Icons.center_focus_strong_rounded,
        label: l.homeTileCheckCrop,
        hint: l.homeTileCheckCropHint,
        tintIndex: 0,
        onTap: () => context.push(Routes.capture),
      ),
      BigActionTile(
        icon: Icons.wb_sunny_rounded,
        label: l.homeTileWeather,
        hint: l.homeTileWeatherHint,
        tintIndex: 3,
        onTap: () => context.push(Routes.weather),
      ),
      BigActionTile(
        icon: Icons.campaign_rounded,
        label: l.homeTileNews,
        hint: l.homeTileNewsHint,
        tintIndex: 1,
        badgeCount: newsCount,
        onTap: () => context.push(Routes.news),
      ),
      BigActionTile(
        icon: Icons.storefront_rounded,
        label: l.homeTileMarket,
        hint: l.homeTileMarketHint,
        tintIndex: 5,
        onTap: () => context.push(Routes.market),
      ),
      // The design system's six tiles, exactly: Check Crop, Ask, Crop Advice,
      // Weather, Krishi Barta, Haat_Bazar. Orders and History used to hold two
      // of these slots, which duplicated the bottom nav and left the assistant
      // and the crop adviser unreachable from Home.
      BigActionTile(
        icon: Icons.forum_rounded,
        label: l.homeTileAsk,
        hint: l.homeTileAskHint,
        tintIndex: 2,
        onTap: () => context.push(Routes.assistant),
      ),
      BigActionTile(
        icon: Icons.agriculture_rounded,
        label: l.homeTileAdvice,
        hint: l.homeTileAdviceHint,
        tintIndex: 4,
        onTap: () => context.push(Routes.cropAdvice),
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < tiles.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: Space.sm),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: tiles[i]),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: i + 1 < tiles.length
                        ? tiles[i + 1]
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Recent photos as a horizontal strip: a farmer who checks a leaf most days
/// needs to *see* the previous ones, not read a list of titles.
class _RecentStrip extends StatelessWidget {
  const _RecentStrip({
    required this.items,
    required this.onOpen,
    required this.onSeeAll,
  });

  final List<Diagnosis> items;
  final void Function(Diagnosis) onOpen;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    // Intrinsic height rather than a fixed strip height. A disease name can run
    // to two lines and Bangla at 1.3x is tall; the old 176dp box clipped the
    // confidence badge out of the bottom of every card, which is exactly the
    // "text floating outside the box" that was reported. Seven cards are cheap
    // enough to measure, and now the tallest card sets the height for all.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final d in items) ...[
              SizedBox(
                width: 168,
                child: _RecentCard(diagnosis: d, onTap: () => onOpen(d)),
              ),
              const SizedBox(width: Space.xs),
            ],
            // One extra slot: the strip ends with the way to the full history,
            // so the last card of a scroll never dead-ends.
            _SeeAllCard(onTap: onSeeAll),
          ],
        ),
      ),
    );
  }
}

/// The end of the strip: a quiet card whose whole job is to continue the list.
class _SeeAllCard extends StatelessWidget {
  const _SeeAllCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;

    return SizedBox(
      width: 116,
      child: Material(
        color: p.surfaceSunken,
        borderRadius: Radii.cardAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.cardAll,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: Radii.cardAll,
              border: Border.all(
                color: p.primary,
                width: p.borderWidth,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Medallion(
                  icon: Icons.arrow_forward_rounded,
                  background: p.surface,
                  foreground: p.primary,
                ),
                const SizedBox(height: Space.xs),
                Text(
                  l.actionSeeAll,
                  textAlign: TextAlign.center,
                  style: context.texts.labelSmall?.copyWith(color: p.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.diagnosis, required this.onTap});

  final Diagnosis diagnosis;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final locale = Localizations.localeOf(context).languageCode;

    final title = diagnosis.canShowDisease
        ? (diagnosis.disease?.label(locale) ?? l.diagnosisResultTitle)
        : l.diagnosisLowTitle;

    return SizedBox(
      width: 164,
      child: AppCard(
        padding: const EdgeInsets.all(Space.sm),
        onTap: onTap,
        semanticLabel: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Medallion(
              icon: Icons.eco_rounded,
              size: Sizes.medallion,
              background: p.surfaceSunken,
              foreground: p.primary,
            ),
            const SizedBox(height: Space.xs),
            Text(
              title,
              style: context.texts.titleSmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              AppFormat.of(context).relative(diagnosis.createdAt),
              style: context.texts.bodySmall,
            ),
            const SizedBox(height: Space.xxs),
            if (diagnosis.canShowDisease)
              ConfidenceBadge(
                score: diagnosis.confidence,
                level: diagnosis.confidenceLevel,
                compact: true,
              )
            else
              Text(
                l.diagnosisConfidenceLow,
                style: context.texts.bodySmall
                    ?.copyWith(color: p.confidenceLow),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentEmptyCard extends StatelessWidget {
  const _RecentEmptyCard({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;

    return AppCard(
      tint: p.surfaceSunken,
      onTap: onScan,
      semanticLabel: l.diagnosisHistoryEmptyBody,
      child: Row(
        children: [
          Medallion(
            icon: Icons.eco_rounded,
            background: p.surface,
            foreground: p.primary,
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.homeRecentEmpty, style: context.texts.titleSmall),
                const SizedBox(height: 2),
                Text(
                  l.diagnosisHistoryEmptyBody,
                  style: context.texts.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: p.onSurfaceMuted),
        ],
      ),
    );
  }
}

class _UrgentBanner extends StatelessWidget {
  const _UrgentBanner({required this.item, required this.onTap});

  final NewsItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;

    return Semantics(
      liveRegion: true,
      button: true,
      label: '${l.homeUrgentTitle}: ${item.titleBn}',
      child: Material(
        color: p.errorContainer,
        borderRadius: Radii.cardAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: Radii.cardAll,
          child: Container(
            padding: const EdgeInsets.all(Space.sm),
            decoration: BoxDecoration(
              borderRadius: Radii.cardAll,
              border: Border.all(color: p.error, width: p.borderWidth),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.campaign_rounded, color: p.error, size: 28),
                const SizedBox(width: Space.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.homeUrgentTitle,
                              style: context.texts.labelSmall
                                  ?.copyWith(color: p.onErrorContainer),
                            ),
                          ),
                          SeverityChip(severity: item.severity, compact: true),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.titleBn,
                        style: context.texts.bodySmall
                            ?.copyWith(color: p.onErrorContainer),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
