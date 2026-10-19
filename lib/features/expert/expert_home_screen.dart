import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/states.dart';
import '../../data/models/growth.dart';
import '../../data/models/ops.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../staff/staff_design.dart';
import '../staff/staff_widgets.dart';
import 'expert_screens.dart';

/// The expert shell's selected tab, shared with the feed so its quick actions
/// can open the queue instead of pushing a second copy of it.
final expertTabProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier<int>(0);
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// The feed, farmer requests, plans, bookings and peers in one call.
final expertDeskProvider = FutureProvider<ExpertDesk>(
  (ref) async => ref.watch(expertRepositoryProvider).desk(),
);

/// The expert's home: a professional feed where their writing is the product.
class ExpertHomeScreen extends ConsumerStatefulWidget {
  const ExpertHomeScreen({super.key});

  @override
  ConsumerState<ExpertHomeScreen> createState() => _ExpertHomeScreenState();
}

class _ExpertHomeScreenState extends ConsumerState<ExpertHomeScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final user = ref.watch(currentUserProvider);
    final desk = ref.watch(expertDeskProvider);
    final tab = ref.watch(expertTabProvider);

    if (user == null) {
      return const Scaffold(body: LoadingState(rows: 3));
    }

    return AppScreen(
      title: l.expertHome,
      showBack: false,
      header: StaffHero(
        eyebrow: l.expertConsoleEyebrow,
        title: user.name,
        subtitle: l.expertConsoleSubtitle,
        initials: user.initials,
        icon: Icons.school_rounded,
        onAvatarTap: () => tab.value = 4,
        actions: [
          IconButton(
            tooltip: l.expertWrite,
            onPressed: () => _write(context, ref),
            icon: const Icon(Icons.edit_square),
          ),
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(expertDeskProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        footer: desk.maybeWhen(
          data: (data) => Row(
            children: [
              _HeroStat(
                value: data.rating.toStringAsFixed(1),
                label: l.expertRating,
                icon: Icons.star_rounded,
              ),
              _HeroStat(
                value: f.number(data.followers),
                label: l.expertFollowers,
                icon: Icons.people_alt_rounded,
              ),
              _HeroStat(
                value: f.number(data.subscribers),
                label: l.expertSubscribers,
                icon: Icons.workspace_premium_rounded,
              ),
              _HeroStat(
                value: l.expertMinutesShort(f.number(data.responseMinutes)),
                label: l.expertResponseTime,
                icon: Icons.bolt_rounded,
              ),
            ],
          ),
          orElse: () => const SizedBox.shrink(),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StaffSectionTitle(
            title: l.staffQuickActions,
            icon: Icons.bolt_rounded,
          ),
          StaffActionGrid(
            children: [
              StaffActionTile(
                icon: Icons.edit_note_rounded,
                label: l.expertWrite,
                onTap: () => _write(context, ref),
              ),
              StaffActionTile(
                icon: Icons.forum_rounded,
                label: l.expertQuestions,
                badge: desk.value?.openQuestions.length,
                tone: p.harvestContainer,
                onTap: () => tab.value = 1,
              ),
              StaffActionTile(
                icon: Icons.video_call_rounded,
                label: l.expertConsultations,
                onTap: () => tab.value = 3,
              ),
              StaffActionTile(
                icon: Icons.auto_stories_rounded,
                label: l.expertStudio,
                onTap: () => tab.value = 2,
              ),
            ],
          ),
          const SizedBox(height: Space.lg),
          desk.when(
            loading: () => const LoadingState(rows: 4),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(expertDeskProvider),
            ),
            data: (data) {
              final next =
                  data.openQuestions.isEmpty ? null : data.openQuestions.first;
              final articles = _filtered(data);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (next != null) ...[
                    StaffNotice(
                      icon: Icons.help_center_rounded,
                      title: l.expertPendingQuestions(
                        f.number(data.openQuestions.length),
                      ),
                      body: '${next.farmerName} · ${next.crop} · '
                          '${f.relative(next.createdAt)}',
                      tone:
                          next.urgent ? p.errorContainer : p.harvestContainer,
                      action: StaffLinkRow(
                        icon: Icons.arrow_forward_rounded,
                        label: l.expertAnswerNow,
                        onTap: () => tab.value = 1,
                      ),
                    ),
                    const SizedBox(height: Space.lg),
                  ],
                  StaffSectionTitle(
                    title: l.expertFeed,
                    icon: Icons.auto_awesome_rounded,
                  ),
                  OpsFilters(
                    labels: [
                      l.expertAllArticles,
                      l.expertMyArticles,
                      l.expertSaved,
                    ],
                    index: _filter,
                    onChanged: (i) => setState(() => _filter = i),
                  ),
                  const SizedBox(height: Space.sm),
                  if (articles.isEmpty)
                    EmptyState(
                      icon: Icons.article_outlined,
                      title: l.expertNoArticles,
                      body: l.expertNoArticlesBody,
                      actionLabel: l.expertWrite,
                      onAction: () => _write(context, ref),
                    )
                  else
                    for (final article in articles)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Space.sm),
                        child: _ArticleCard(
                          article: article,
                          onTap: () => _openArticle(context, article),
                          onLike: () => _like(article.id),
                          onSave: () => _save(article.id),
                        ),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<ExpertArticle> _filtered(ExpertDesk data) => switch (_filter) {
        1 => data.articles.where((a) => a.mine).toList(growable: false),
        2 => data.articles.where((a) => a.saved).toList(growable: false),
        _ => data.articles,
      };

  Future<void> _like(String id) async {
    await ref.read(expertRepositoryProvider).toggleLike(id);
    ref.invalidate(expertDeskProvider);
  }

  Future<void> _save(String id) async {
    await ref.read(expertRepositoryProvider).toggleSaved(id);
    ref.invalidate(expertDeskProvider);
  }

  Future<void> _write(BuildContext context, WidgetRef ref) async {
    final l = AppL10n.of(context);
    final saved = await showStaffSheet<bool>(
      context,
      title: l.expertWrite,
      child: const _WriteArticleSheet(),
    );
    if (saved == true && context.mounted) {
      ref.invalidate(expertDeskProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.expertArticlePublished)),
      );
    }
  }

  void _openArticle(BuildContext context, ExpertArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticleScreen(articleId: article.id),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ink = context.palette.onPrimary;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: ink.withValues(alpha: 0.8)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.titleSmall?.copyWith(
              color: ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.texts.labelSmall?.copyWith(
              color: ink.withValues(alpha: 0.76),
            ),
          ),
        ],
      ),
    );
  }
}

/// A feed card. The painted cover is built from the palette rather than a photo
/// URL, so the feed never shows an empty grey box offline.
class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.onTap,
    required this.onLike,
    required this.onSave,
  });

  final ExpertArticle article;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final (start, end, icon) = _cover(context, article.coverTone);

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radii.card),
            child: Container(
              height: 96,
              padding: const EdgeInsets.all(Space.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [start, end],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -8,
                    bottom: -18,
                    child: Icon(
                      icon,
                      size: 96,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Wrap(
                      spacing: Space.xs,
                      runSpacing: 4,
                      children: [
                        _CoverPill(label: article.crop),
                        if (article.mine) _CoverPill(label: l.expertMine),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Space.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall,
                ),
                const SizedBox(height: Space.xs),
                Row(
                  children: [
                    StaffAvatar(
                      initials: staffInitials(article.authorName),
                      size: 28,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        article.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.labelSmall,
                      ),
                    ),
                    StaffRating(
                      rating: article.rating,
                      count: article.ratingCount,
                      size: 13,
                    ),
                  ],
                ),
                const SizedBox(height: Space.xxs),
                Row(
                  children: [
                    _CountAction(
                      icon: article.liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      label: f.number(article.likes),
                      onTap: onLike,
                      color: article.liked ? p.error : p.onSurfaceMuted,
                    ),
                    const SizedBox(width: Space.sm),
                    _CountAction(
                      icon: Icons.mode_comment_outlined,
                      label: f.number(article.comments.length),
                      onTap: onTap,
                    ),
                    const SizedBox(width: Space.sm),
                    _CountAction(
                      icon: Icons.visibility_outlined,
                      label: f.number(article.views),
                      onTap: onTap,
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip:
                          article.saved ? l.expertUnsave : l.expertSave,
                      onPressed: onSave,
                      icon: Icon(
                        article.saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: article.saved ? p.primary : p.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, IconData) _cover(BuildContext context, int tone) {
    final p = context.palette;
    return switch (tone) {
      1 => (p.severityHigh, p.harvest, Icons.pest_control_rounded),
      2 => (const Color(0xFF4A3A0F), p.harvest, Icons.grain_rounded),
      3 => (const Color(0xFF123A2A), p.primary, Icons.terrain_rounded),
      _ => (p.primaryDark, p.primary, Icons.eco_rounded),
    };
  }

}

class _CoverPill extends StatelessWidget {
  const _CoverPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: Radii.chipAll,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: context.texts.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CountAction extends StatelessWidget {
  const _CountAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.chipAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Space.xs,
          vertical: Space.xxs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color ?? p.onSurfaceMuted),
            const SizedBox(width: 4),
            Text(
              label,
              style: context.texts.labelSmall?.copyWith(
                color: color ?? p.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One article, with rating, comments and the composer. A route rather than a
/// sheet because it is a reading surface first and a form second.
class ArticleScreen extends ConsumerWidget {
  const ArticleScreen({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final async = ref.watch(expertDeskProvider);

    return AppScreen(
      title: l.expertFeed,
      header: StaffTabHeader(
        title: l.expertFeed,
        subtitle: l.expertReadArticle,
        icon: Icons.auto_stories_rounded,
        showBack: true,
      ),
      child: async.when(
        loading: () => const LoadingState(rows: 4),
        error: (error, _) => ErrorState(
          body: staffErrorText(error, l),
          onRetry: () => ref.invalidate(expertDeskProvider),
        ),
        data: (desk) {
          ExpertArticle? article;
          for (final item in desk.articles) {
            if (item.id == articleId) article = item;
          }
          if (article == null) {
            return EmptyState(
              icon: Icons.article_outlined,
              title: l.stateEmptyTitle,
              body: l.stateEmptyBody,
            );
          }
          final current = article;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(current.title, style: context.texts.headlineSmall),
              const SizedBox(height: Space.xxs),
              Text(
                '${current.authorName} · ${current.authorTitle}',
                style: context.texts.bodySmall
                    ?.copyWith(color: p.onSurfaceMuted),
              ),
              Text(
                '${f.longDate(current.publishedAt)} · '
                '${l.expertViewsCount(f.number(current.views))}',
                style: context.texts.labelSmall
                    ?.copyWith(color: p.onSurfaceMuted),
              ),
              const SizedBox(height: Space.sm),
              Row(
                children: [
                  Expanded(
                    child: StaffRating(
                      rating: current.rating,
                      count: current.ratingCount,
                    ),
                  ),
                  IconButton(
                    tooltip: current.liked ? l.expertUnlike : l.expertLike,
                    onPressed: () async {
                      await ref
                          .read(expertRepositoryProvider)
                          .toggleLike(current.id);
                      ref.invalidate(expertDeskProvider);
                    },
                    icon: Icon(
                      current.liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: current.liked ? p.error : p.onSurfaceMuted,
                    ),
                  ),
                  IconButton(
                    tooltip: current.saved ? l.expertUnsave : l.expertSave,
                    onPressed: () async {
                      await ref
                          .read(expertRepositoryProvider)
                          .toggleSaved(current.id);
                      ref.invalidate(expertDeskProvider);
                    },
                    icon: Icon(
                      current.saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: current.saved ? p.primary : p.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Space.xs),
              Text(current.body, style: context.texts.bodyMedium),
              const SizedBox(height: Space.md),
              Text(
                l.expertRateArticle,
                style: context.texts.labelMedium
                    ?.copyWith(color: p.onSurfaceMuted),
              ),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      tooltip: l.expertRateStars(i),
                      onPressed: () async {
                        await ref
                            .read(expertRepositoryProvider)
                            .rateArticle(current.id, i);
                        ref.invalidate(expertDeskProvider);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.expertRatingThanks)),
                          );
                        }
                      },
                      icon: Icon(
                        i <= current.rating.round()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: p.harvest,
                      ),
                    ),
                ],
              ),
              const Divider(),
              Text(
                l.expertCommentsCount(f.number(current.comments.length)),
                style: context.texts.titleSmall,
              ),
              const SizedBox(height: Space.xs),
              if (current.comments.isEmpty)
                AppCard(
                  child: Text(
                    l.expertNoComments,
                    style: context.texts.bodySmall,
                  ),
                )
              else
                for (final comment in current.comments)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: _CommentCard(comment: comment),
                  ),
              const SizedBox(height: Space.sm),
              _CommentComposer(articleId: current.id),
            ],
          );
        },
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment});

  final ArticleComment comment;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final f = AppFormat.of(context);

    return AppCard(
      padding: const EdgeInsets.all(Space.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StaffAvatar(
            size: 32,
            icon: comment.isExpert ? Icons.school_rounded : Icons.person_rounded,
          ),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.texts.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (comment.isExpert)
                      OpsPill(
                        label: AppL10n.of(context).roleExpert,
                        tone: OpsTone.primary,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(comment.body, style: context.texts.bodySmall),
                Text(
                  f.relative(comment.at),
                  style: context.texts.labelSmall
                      ?.copyWith(color: p.onSurfaceMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentComposer extends ConsumerStatefulWidget {
  const _CommentComposer({required this.articleId});

  final String articleId;

  @override
  ConsumerState<_CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends ConsumerState<_CommentComposer> {
  final _text = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: TextField(
            controller: _text,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(hintText: l.expertAddComment),
          ),
        ),
        const SizedBox(width: Space.xs),
        IconButton.filled(
          tooltip: l.expertSend,
          onPressed: _sending ? null : _send,
          icon: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.send_rounded),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    final l = AppL10n.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(expertRepositoryProvider)
          .commentOnArticle(widget.articleId, text);
      ref.invalidate(expertDeskProvider);
      _text.clear();
      if (mounted) setState(() => _sending = false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }
}

class _WriteArticleSheet extends ConsumerStatefulWidget {
  const _WriteArticleSheet();

  @override
  ConsumerState<_WriteArticleSheet> createState() =>
      _WriteArticleSheetState();
}

class _WriteArticleSheetState extends ConsumerState<_WriteArticleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _body = TextEditingController();
  String _crop = 'ধান';
  bool _saving = false;

  static const _crops = ['ধান', 'আলু', 'টমেটো', 'সব ফসল'];

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    String? required(String? value) =>
        (value ?? '').trim().isEmpty ? l.vendorFieldRequired : null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          StaffField(
            controller: _title,
            label: l.expertArticleTitle,
            validator: required,
          ),
          StaffField(
            controller: _summary,
            label: l.expertArticleSummary,
            maxLines: 2,
            validator: required,
          ),
          StaffField(
            controller: _body,
            label: l.expertArticleBody,
            maxLines: 8,
            validator: required,
          ),
          StaffChoice<String>(
            label: l.expertArticleCrop,
            selected: _crop,
            options: [for (final c in _crops) (value: c, label: c)],
            onChanged: (value) => setState(() => _crop = value),
          ),
          AppButton(
            label: l.expertPublish,
            isLoading: _saving,
            onPressed: _save,
          ),
          const SizedBox(height: Space.xs),
          AppButton(
            label: l.actionCancel,
            tone: AppButtonTone.quiet,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l = AppL10n.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(expertRepositoryProvider).publishArticle(
            title: _title.text.trim(),
            summary: _summary.text.trim(),
            body: _body.text.trim(),
            crop: _crop,
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }
}

/// Farmer requests. These are not articles: each one has a person behind it and
/// a mode they asked for, so the card leads with both.
class ExpertQuestionsScreen extends ConsumerStatefulWidget {
  const ExpertQuestionsScreen({super.key});

  @override
  ConsumerState<ExpertQuestionsScreen> createState() =>
      _ExpertQuestionsScreenState();
}

class _ExpertQuestionsScreenState extends ConsumerState<ExpertQuestionsScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final async = ref.watch(expertDeskProvider);
    final tab = ref.watch(expertTabProvider);

    return AppScreen(
      title: l.expertQuestions,
      showBack: false,
      header: StaffTabHeader(
        title: l.expertQuestions,
        subtitle: l.expertQuestionsSubtitle,
        icon: Icons.forum_rounded,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(expertDeskProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: async.when(
        loading: () => const LoadingState(rows: 4),
        error: (error, _) => ErrorState(
          body: staffErrorText(error, l),
          onRetry: () => ref.invalidate(expertDeskProvider),
        ),
        data: (data) {
          final pending = data.questions
              .where((q) => !q.answered)
              .toList(growable: false);
          final answered = data.questions
              .where((q) => q.answered)
              .toList(growable: false);
          final shown = _filter == 0 ? pending : answered;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OpsFilters(
                labels: [
                  l.expertOpenTab(pending.length),
                  l.expertAnsweredTab(answered.length),
                ],
                index: _filter,
                onChanged: (i) => setState(() => _filter = i),
              ),
              const SizedBox(height: Space.md),
              if (shown.isEmpty)
                EmptyState(
                  icon: Icons.forum_rounded,
                  title: l.expertNoQuestions,
                  body: l.expertNoQuestionsBody,
                  actionLabel: l.expertConsultations,
                  onAction: () => tab.value = 3,
                )
              else
                for (final question in shown)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: _QuestionCard(question: question),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _QuestionCard extends ConsumerWidget {
  const _QuestionCard({required this.question});

  final ExpertQuestion question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final (modeLabel, modeIcon, modeTone) = _mode(l, question.mode);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaffAvatar(initials: staffInitials(question.farmerName)),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.farmerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.titleSmall,
                    ),
                    Text(
                      '${question.farmerDistrict} · ${question.crop} · '
                      '${f.relative(question.createdAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.texts.bodySmall
                          ?.copyWith(color: p.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
              if (question.urgent)
                OpsPill(label: l.expertUrgent, tone: OpsTone.danger),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(question.question, style: context.texts.bodyMedium),
          if (question.reply != null) ...[
            const SizedBox(height: Space.xs),
            Container(
              padding: const EdgeInsets.all(Space.xs),
              decoration: BoxDecoration(
                color: p.surfaceSunken,
                borderRadius: Radii.fieldAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.subdirectory_arrow_right_rounded,
                    size: 18,
                    color: p.onSurfaceMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      question.reply!,
                      style: context.texts.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: Space.xs),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OpsPill(label: modeLabel, tone: modeTone),
              if (question.mode == 'call' || question.mode == 'video')
                AppButton(
                  label: question.mode == 'video'
                      ? l.staffVideo
                      : l.staffCall,
                  icon: modeIcon,
                  tone: AppButtonTone.secondary,
                  expand: false,
                  onPressed: () => _comingSoon(context, l),
                ),
              if (!question.answered)
                AppButton(
                  label: l.expertAnswer,
                  icon: Icons.reply_rounded,
                  expand: false,
                  onPressed: () => _answer(context, ref),
                ),
            ],
          ),
        ],
      ),
    );
  }

  (String, IconData, OpsTone) _mode(AppL10n l, String mode) => switch (mode) {
        'video' => (l.expertModeVideo, Icons.videocam_rounded, OpsTone.danger),
        'call' => (l.expertModeCall, Icons.call_rounded, OpsTone.warning),
        _ => (l.expertModeMessage, Icons.sms_rounded, OpsTone.primary),
      };

  void _comingSoon(BuildContext context, AppL10n l) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.staffComingSoon)),
    );
  }

  Future<void> _answer(BuildContext context, WidgetRef ref) async {
    final saved = await showStaffSheet<bool>(
      context,
      title: AppL10n.of(context).expertAnswer,
      child: _AnswerSheet(question: question),
    );
    if (saved == true) {
      ref.invalidate(expertDeskProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).expertAnsweredNow)),
        );
      }
    }
  }

}

class _AnswerSheet extends ConsumerStatefulWidget {
  const _AnswerSheet({required this.question});

  final ExpertQuestion question;

  @override
  ConsumerState<_AnswerSheet> createState() => _AnswerSheetState();
}

class _AnswerSheetState extends ConsumerState<_AnswerSheet> {
  late final TextEditingController _reply = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _reply.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppCard(
          tint: p.surfaceSunken,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.question.farmerName,
                  style: context.texts.titleSmall),
              Text(widget.question.question, style: context.texts.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
        TextField(
          controller: _reply,
          autofocus: true,
          minLines: 4,
          maxLines: 8,
          decoration: InputDecoration(
            labelText: l.expertAnswer,
            hintText: l.expertReplyHint,
          ),
        ),
        const SizedBox(height: Space.sm),
        AppButton(
          label: l.expertSend,
          isLoading: _saving,
          onPressed: _send,
        ),
        const SizedBox(height: Space.xs),
        AppButton(
          label: l.actionCancel,
          tone: AppButtonTone.quiet,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final text = _reply.text.trim();
    if (text.isEmpty) return;
    final l = AppL10n.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(expertRepositoryProvider)
          .answerQuestion(widget.question.id, text);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(staffErrorText(error, l))),
      );
    }
  }
}

/// The studio gathers the editorial tools that already existed (reviews, news,
/// knowledge) behind one painted door, plus the expert's own writing stats.
class ExpertStudioScreen extends ConsumerWidget {
  const ExpertStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final async = ref.watch(expertDeskProvider);
    final reviews = ref.watch(expertReviewsProvider);
    final news = ref.watch(expertNewsProvider);

    void open(Widget screen) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
      );
    }

    return AppScreen(
      title: l.expertStudio,
      showBack: false,
      header: StaffTabHeader(
        title: l.expertStudio,
        subtitle: l.expertStudioSubtitle,
        icon: Icons.auto_stories_rounded,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () {
              ref.invalidate(expertDeskProvider);
              ref.invalidate(expertReviewsProvider);
              ref.invalidate(expertNewsProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          async.when(
            loading: () => const LoadingState(rows: 2),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(expertDeskProvider),
            ),
            data: (data) => StaffKpiRow(
              left: StaffKpi(
                value: f.number(data.articles.where((a) => a.mine).length),
                label: l.expertMyArticles,
                icon: Icons.edit_note_rounded,
              ),
              right: StaffKpi(
                value: f.number(
                  data.articles
                      .where((a) => a.mine)
                      .fold<int>(0, (sum, a) => sum + a.views),
                ),
                label: l.expertTotalViews,
                icon: Icons.visibility_rounded,
                tone: p.harvestContainer,
              ),
            ),
          ),
          const SizedBox(height: Space.lg),
          StaffSectionTitle(
            title: l.expertEditorialTools,
            icon: Icons.dashboard_customize_rounded,
          ),
          _StudioDoor(
            icon: Icons.fact_check_rounded,
            title: l.expertReviewQueue,
            body: l.expertReviewQueueBody,
            count: reviews.value
                ?.where((c) => !c.resolved)
                .length,
            onTap: () => open(const ExpertReviewsScreen()),
          ),
          const SizedBox(height: Space.xs),
          _StudioDoor(
            icon: Icons.campaign_rounded,
            title: l.expertNewsPipeline,
            body: l.expertNewsPipelineBody,
            count: news.value
                ?.where((d) => d.status != DraftStatus.published)
                .length,
            onTap: () => open(const ExpertNewsScreen()),
          ),
          const SizedBox(height: Space.xs),
          _StudioDoor(
            icon: Icons.menu_book_rounded,
            title: l.expertKnowledgeBase,
            body: l.expertKnowledgeBody,
            onTap: () => open(const ExpertKnowledgeScreen()),
          ),
          const SizedBox(height: Space.lg),
          StaffSectionTitle(
            title: l.expertInbox,
            icon: Icons.inbox_rounded,
          ),
          AppCard(
            child: Column(
              children: [
                StaffInfoRow(
                  icon: Icons.forum_rounded,
                  label: l.expertQuestions,
                  value: f.number(
                    async.value?.questions
                            .where((q) => !q.answered)
                            .length ??
                        0,
                  ),
                ),
                StaffInfoRow(
                  icon: Icons.workspace_premium_rounded,
                  label: l.expertSubscribers,
                  value: f.number(async.value?.subscribers ?? 0),
                ),
                StaffInfoRow(
                  icon: Icons.payments_rounded,
                  label: l.expertEarnings,
                  value: f.taka(async.value?.earnings ?? 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StudioDoor extends StatelessWidget {
  const _StudioDoor({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.count,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.primaryContainer,
              borderRadius: Radii.fieldAll,
            ),
            child: Icon(icon, color: p.onPrimaryContainer),
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.texts.titleSmall),
                Text(
                  body,
                  style: context.texts.bodySmall
                      ?.copyWith(color: p.onSurfaceMuted),
                ),
              ],
            ),
          ),
          if (count != null && count! > 0) StaffCountBadge(count: count!),
          Icon(Icons.chevron_right_rounded, color: p.onSurfaceMuted),
        ],
      ),
    );
  }
}

/// Subscriptions and the calls they buy. This is the expert's business tab.
class ExpertConsultationsScreen extends ConsumerStatefulWidget {
  const ExpertConsultationsScreen({super.key});

  @override
  ConsumerState<ExpertConsultationsScreen> createState() =>
      _ExpertConsultationsScreenState();
}

class _ExpertConsultationsScreenState
    extends ConsumerState<ExpertConsultationsScreen> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final async = ref.watch(expertDeskProvider);

    return AppScreen(
      title: l.expertConsultations,
      showBack: false,
      header: StaffTabHeader(
        title: l.expertConsultations,
        subtitle: l.expertConsultationsSubtitle,
        icon: Icons.video_call_rounded,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(expertDeskProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: async.when(
        loading: () => const LoadingState(rows: 4),
        error: (error, _) => ErrorState(
          body: staffErrorText(error, l),
          onRetry: () => ref.invalidate(expertDeskProvider),
        ),
        data: (data) {
          final f = AppFormat.of(context);
          final p = context.palette;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StaffKpiRow(
                left: StaffKpi(
                  value: f.taka(data.earnings),
                  label: l.expertEarnings,
                  icon: Icons.payments_rounded,
                ),
                right: StaffKpi(
                  value: f.number(data.subscribers),
                  label: l.expertSubscribers,
                  icon: Icons.workspace_premium_rounded,
                  tone: p.harvestContainer,
                ),
              ),
              const SizedBox(height: Space.md),
              OpsFilters(
                labels: [l.expertPlans, l.expertCalls],
                index: _mode,
                onChanged: (i) => setState(() => _mode = i),
              ),
              const SizedBox(height: Space.md),
              if (_mode == 0) ...[
                for (final plan in data.plans)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: _PlanCard(plan: plan),
                  ),
              ] else ...[
                if (data.bookings.isEmpty)
                  EmptyState(
                    icon: Icons.video_call_rounded,
                    title: l.expertNoCalls,
                    body: l.expertNoCallsBody,
                  )
                else
                  for (final booking in data.bookings)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: _BookingCard(booking: booking),
                    ),
              ],
              const SizedBox(height: Space.lg),
              StaffSectionTitle(
                title: l.expertNetwork,
                icon: Icons.handshake_rounded,
              ),
              for (final peer in data.peers)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.xs),
                  child: _PeerCard(peer: peer),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.plan});

  final ConsultationPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(plan.title, style: context.texts.titleSmall),
              ),
              OpsPill(
                label: plan.active ? l.expertPlanActive : l.expertPlanPaused,
                tone: plan.active ? OpsTone.success : OpsTone.neutral,
              ),
              Switch.adaptive(
                value: plan.active,
                onChanged: (value) async {
                  await ref
                      .read(expertRepositoryProvider)
                      .togglePlan(plan.id, value);
                  ref.invalidate(expertDeskProvider);
                },
              ),
            ],
          ),
          Text(
            '${f.taka(plan.price)} · ${l.expertPerPeriod(plan.period)}',
            style: context.texts.titleMedium?.copyWith(color: p.primary),
          ),
          const SizedBox(height: Space.xxs),
          Row(
            children: [
              Icon(
                Icons.people_alt_rounded,
                size: 16,
                color: p.onSurfaceMuted,
              ),
              const SizedBox(width: 4),
              Text(
                l.expertSubscribersCount(f.number(plan.subscribers)),
                style: context.texts.bodySmall
                    ?.copyWith(color: p.onSurfaceMuted),
              ),
            ],
          ),
          const SizedBox(height: Space.xxs),
          for (final perk in plan.perks)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_rounded, size: 15, color: p.success),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(perk, style: context.texts.bodySmall),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final ConsultationBooking booking;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final upcoming = booking.status == 'upcoming';

    return AppCard(
      child: Row(
        children: [
          StaffAvatar(
            icon: booking.mode == 'video'
                ? Icons.videocam_rounded
                : Icons.call_rounded,
          ),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.farmerName, style: context.texts.titleSmall),
                Text(
                  booking.topic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall
                      ?.copyWith(color: p.onSurfaceMuted),
                ),
                Text(
                  '${f.dateTime(booking.at)} · '
                  '${l.expertMinutes(f.number(booking.minutes))}',
                  maxLines: 2,
                  style: context.texts.labelSmall
                      ?.copyWith(color: p.onSurfaceMuted),
                ),
              ],
            ),
          ),
          if (upcoming)
            AppButton(
              label: l.expertJoinCall,
              expand: false,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.staffComingSoon)),
                );
              },
            )
          else
            OpsPill(label: l.staffCompleted, tone: OpsTone.success),
        ],
      ),
    );
  }
}

class _PeerCard extends ConsumerWidget {
  const _PeerCard({required this.peer});

  final ExpertPeer peer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;

    return AppCard(
      child: Row(
        children: [
          StaffAvatar(initials: staffInitials(peer.name)),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  peer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.titleSmall,
                ),
                Text(
                  '${peer.specialization} · ${peer.district}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.texts.bodySmall
                      ?.copyWith(color: p.onSurfaceMuted),
                ),
                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 15, color: p.harvest),
                    const SizedBox(width: 2),
                    Text(
                      '${peer.rating.toStringAsFixed(1)} · '
                      '${l.expertFollowersCount(f.number(peer.followers))}',
                      style: context.texts.labelSmall
                          ?.copyWith(color: p.onSurfaceMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          AppButton(
            label: peer.connected ? l.expertConnected : l.expertConnect,
            tone:
                peer.connected ? AppButtonTone.quiet : AppButtonTone.secondary,
            expand: false,
            onPressed: () async {
              await ref
                  .read(expertRepositoryProvider)
                  .toggleConnect(peer.id);
              ref.invalidate(expertDeskProvider);
            },
          ),
        ],
      ),
    );
  }

}
