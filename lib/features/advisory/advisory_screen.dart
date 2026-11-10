import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/ambience.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/states.dart';
import '../../data/models/enums.dart';
import '../../data/models/growth.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';

/// The advisory feed: expert-written, published articles.
///
/// Separate from Krishi Barta on purpose. News is about an outbreak happening
/// now; an article is evergreen guidance. Mixing them would bury the urgent
/// alert under a how-to.
final advisoryListProvider = FutureProvider<List<ExpertArticle>>(
  (ref) => ref.watch(articleRepositoryProvider).articles(),
);

final articleProvider = FutureProvider.family<ExpertArticle, String>(
  (ref, id) => ref.watch(articleRepositoryProvider).article(id),
);

class AdvisoryScreen extends ConsumerWidget {
  const AdvisoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final async = ref.watch(advisoryListProvider);

    return AppScreen(
      title: l.advisoryTitle,
      ambience: AmbienceMood.news,
      actions: [
        IconButton(
          tooltip: l.actionRetry,
          onPressed: () => ref.invalidate(advisoryListProvider),
          icon: const Icon(Icons.refresh_rounded),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.advisorySubtitle,
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
          const SizedBox(height: Space.sm),
          OutlinedButton.icon(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (_) => const _AskExpertSheet(),
            ),
            icon: const Icon(Icons.support_agent_rounded),
            label: Text(l.askExpert),
          ),
          const SizedBox(height: Space.md),
          async.when(
            loading: () => const LoadingState(rows: 3),
            error: (_, _) => ErrorState(
              onRetry: () => ref.invalidate(advisoryListProvider),
            ),
            data: (articles) {
              if (articles.isEmpty) {
                return EmptyState(
                  icon: Icons.menu_book_outlined,
                  title: l.stateEmptyTitle,
                  body: l.stateEmptyBody,
                );
              }
              return Column(
                children: [
                  for (final article in articles)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: _ArticleTile(article: article),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});

  final ExpertArticle article;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final f = AppFormat.of(context);

    return AppCard(
      padding: const EdgeInsets.all(Space.sm),
      onTap: () => context.push('/advisory/${article.id}'),
      semanticLabel: article.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            article.title,
            style: context.texts.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Space.xxs),
          Text(
            article.summary,
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Space.xs),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.person_outline_rounded, size: 16, color: p.onSurfaceMuted),
              Text(
                article.authorName,
                style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
              ),
              Icon(Icons.favorite_border_rounded, size: 16, color: p.onSurfaceMuted),
              Text(
                '${article.likes}',
                style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
              ),
              Icon(Icons.forum_outlined, size: 16, color: p.onSurfaceMuted),
              Text(
                '${article.comments.length}',
                style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
              ),
              Text(
                f.relative(article.publishedAt),
                style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One article, with the four things a reader can do: like, save, rate, comment.
class ArticleScreen extends ConsumerStatefulWidget {
  const ArticleScreen({super.key, required this.articleId});

  final String articleId;

  @override
  ConsumerState<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends ConsumerState<ArticleScreen> {
  final _comment = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _run(Future<ExpertArticle> Function() action) async {
    try {
      await action();
      ref.invalidate(articleProvider(widget.articleId));
      ref.invalidate(advisoryListProvider);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).stateErrorBody)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final p = context.palette;
    final f = AppFormat.of(context);
    final async = ref.watch(articleProvider(widget.articleId));

    return AppScreen(
      title: l.advisoryTitle,
      ambience: AmbienceMood.news,
      child: async.when(
        loading: () => const LoadingState(rows: 4),
        error: (_, _) => ErrorState(
          onRetry: () => ref.invalidate(articleProvider(widget.articleId)),
        ),
        data: (article) {
          final repo = ref.read(articleRepositoryProvider);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(article.title, style: context.texts.headlineSmall),
              const SizedBox(height: Space.xs),
              Text(
                '${article.authorName}${article.authorTitle.isEmpty ? '' : ' · ${article.authorTitle}'}',
                style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
              ),
              const SizedBox(height: Space.xxs),
              Text(
                '${f.relative(article.publishedAt)} · ${article.views} ${l.articleReads}',
                style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
              ),
              const SizedBox(height: Space.md),
              Text(article.summary, style: context.texts.titleSmall),
              const SizedBox(height: Space.sm),
              Text(article.body, style: context.texts.bodyMedium),
              const SizedBox(height: Space.md),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _run(() => repo.toggleLike(article.id)),
                    icon: Icon(
                      article.liked
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                    ),
                    label: Text('${article.likes}'),
                  ),
                  IconButton(
                    tooltip: article.saved ? l.actionSave : l.actionSave,
                    onPressed: () => _run(() => repo.toggleSave(article.id)),
                    icon: Icon(
                      article.saved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                  ),
                  const Spacer(),
                  _Stars(
                    value: article.rating,
                    onRate: (rating) => _run(() => repo.rate(article.id, rating)),
                  ),
                ],
              ),
              const Divider(height: Space.lg),
              Text(l.articleComments, style: context.texts.titleSmall),
              const SizedBox(height: Space.xs),
              if (article.comments.isEmpty)
                Text(
                  l.articleNoComments,
                  style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
                ),
              for (final comment in article.comments)
                Padding(
                  padding: const EdgeInsets.only(bottom: Space.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(comment.authorName, style: context.texts.labelLarge),
                          if (comment.isExpert) ...[
                            const SizedBox(width: Space.xxs),
                            Icon(Icons.verified_rounded, size: 14, color: p.primary),
                          ],
                          const Spacer(),
                          Text(
                            f.relative(comment.at),
                            style: context.texts.bodySmall
                                ?.copyWith(color: p.onSurfaceMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: Space.xxs),
                      Text(comment.body, style: context.texts.bodyMedium),
                    ],
                  ),
                ),
              const SizedBox(height: Space.xs),
              TextField(
                controller: _comment,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(hintText: l.articleCommentHint),
              ),
              const SizedBox(height: Space.xs),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FilledButton(
                  onPressed: _sending
                      ? null
                      : () async {
                          final body = _comment.text.trim();
                          if (body.isEmpty) return;
                          setState(() => _sending = true);
                          await _run(() => repo.comment(article.id, body));
                          if (!mounted) return;
                          _comment.clear();
                          setState(() => _sending = false);
                        },
                  child: Text(l.actionSave),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value, required this.onRate});

  final double value;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++)
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: () => onRate(star),
            icon: Icon(
              value >= star ? Icons.star_rounded : Icons.star_border_rounded,
              size: 20,
              color: value >= star ? p.harvest : p.onSurfaceMuted,
            ),
          ),
      ],
    );
  }
}

/// Sends a question to the shared expert queue.
///
/// The copy is deliberately honest: the farmer is told a reply will be notified,
/// not promised a time, because no one is on call.
class _AskExpertSheet extends ConsumerStatefulWidget {
  const _AskExpertSheet();

  @override
  ConsumerState<_AskExpertSheet> createState() => _AskExpertSheetState();
}

class _AskExpertSheetState extends ConsumerState<_AskExpertSheet> {
  final _question = TextEditingController();
  CropType _crop = CropType.rice;
  bool _urgent = false;
  bool _sending = false;

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _question.text.trim();
    if (text.length < 10) return;

    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final l = AppL10n.of(context);
    try {
      await ref.read(articleRepositoryProvider).ask(
            question: text,
            crop: _crop.wire,
            urgent: _urgent,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      messenger.showSnackBar(SnackBar(content: Text(l.askExpertSent)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      messenger.showSnackBar(SnackBar(content: Text(l.stateErrorBody)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.md,
        Space.md,
        Space.md,
        MediaQuery.viewInsetsOf(context).bottom + Space.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.askExpert, style: context.texts.titleMedium),
          const SizedBox(height: Space.sm),
          TextField(
            controller: _question,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(hintText: l.askExpertHint),
          ),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.xs,
            children: [
              for (final crop in CropType.values)
                ChoiceChip(
                  label: Text(crop.label(l)),
                  selected: _crop == crop,
                  onSelected: (_) => setState(() => _crop = crop),
                ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.askExpertUrgent),
            value: _urgent,
            onChanged: (value) => setState(() => _urgent = value),
          ),
          const SizedBox(height: Space.xs),
          FilledButton(
            onPressed: _sending ? null : _send,
            child: Text(l.askExpert),
          ),
        ],
      ),
    );
  }
}
