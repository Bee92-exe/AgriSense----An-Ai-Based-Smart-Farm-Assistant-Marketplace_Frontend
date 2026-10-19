import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/states.dart';
import '../../data/models/diagnosis.dart';
import '../../data/models/enums.dart';
import '../../data/models/ops.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../staff/staff_design.dart';
import '../staff/staff_widgets.dart';

/// The expert's review queue: every diagnosis the AI was not sure enough about
/// (below the 0.70 floor) is routed here rather than shown to a farmer as an
/// answer (FR-24, FR-25).
final expertReviewsProvider = FutureProvider<List<ReviewCase>>(
  (ref) async => ref.watch(expertRepositoryProvider).reviews(),
);

final expertNewsProvider = FutureProvider<List<NewsDraft>>(
  (ref) async => ref.watch(expertRepositoryProvider).news(),
);

final expertKnowledgeProvider =
    FutureProvider.family<List<KnowledgeEntry>, String>((ref, query) async {
  return ref.watch(expertRepositoryProvider).knowledge(query: query);
});

final _diseasesForCropProvider =
    FutureProvider.family<List<Disease>, CropType?>((ref, crop) async {
  return ref.watch(expertRepositoryProvider).diseasesFor(crop);
});

class ExpertReviewsScreen extends ConsumerStatefulWidget {
  const ExpertReviewsScreen({super.key});

  @override
  ConsumerState<ExpertReviewsScreen> createState() =>
      _ExpertReviewsScreenState();
}

class _ExpertReviewsScreenState extends ConsumerState<ExpertReviewsScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final async = ref.watch(expertReviewsProvider);

    return AppScreen(
      title: l.navReviews,
      showBack: false,
      header: StaffTabHeader(
        title: l.navReviews,
        subtitle: l.expertReviewsSubtitle,
        icon: Icons.fact_check_rounded,
        showBack: true,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(expertReviewsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: async.when(
        loading: () => const LoadingState(rows: 4),
        error: (error, _) => ErrorState(
          body: staffErrorText(error, l),
          onRetry: () => ref.invalidate(expertReviewsProvider),
        ),
        data: (cases) {
          final pending = cases.where((c) => !c.resolved).toList(growable: false);
          final resolved = cases.where((c) => c.resolved).toList(growable: false);
          final shown = _filter == 0 ? pending : resolved;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OpsFilters(
                labels: [
                  l.expertTabPending(pending.length.toString()),
                  l.expertTabResolved(resolved.length.toString()),
                ],
                index: _filter,
                onChanged: (i) => setState(() => _filter = i),
              ),
              const SizedBox(height: Space.md),
              if (shown.isEmpty)
                EmptyState(
                  icon: Icons.fact_check_rounded,
                  title: l.expertQueueEmpty,
                  body: l.expertQueueEmptyBody,
                )
              else
                for (final item in shown)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: _ReviewCard(item: item),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _ReviewCard extends ConsumerWidget {
  const _ReviewCard({required this.item});

  final ReviewCase item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Space.xs,
            runSpacing: Space.xxs,
            children: [
              Text(item.farmerName, style: context.texts.titleSmall),
              if (item.needsRetake)
                OpsPill(label: l.expertNeedsRetake, tone: OpsTone.warning)
              else if (item.resolved)
                OpsPill(label: l.expertResolved, tone: OpsTone.success)
              else
                OpsPill(
                  label: item.level.label(l),
                  tone: OpsTone.neutral,
                ),
            ],
          ),
          const SizedBox(height: Space.xxs),
          Text(
            '${item.farmerDistrict} · '
            '${item.crop?.label(l) ?? l.expertCropUnknown} · '
            '${f.relative(item.createdAt)}',
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
          const SizedBox(height: Space.xs),
          ConfidenceBadge(score: item.confidence),
          if (item.top3.isNotEmpty) ...[
            const SizedBox(height: Space.xs),
            Row(
              children: [
                const AiBadge(),
                const SizedBox(width: Space.xs),
                Expanded(
                  child: Text(
                    l.expertAiGuess,
                    style: context.texts.bodySmall
                        ?.copyWith(color: p.onSurfaceMuted),
                  ),
                ),
              ],
            ),
            for (final (disease, score) in item.top3)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        disease.nameBn,
                        style: context.texts.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Space.xs),
                    Text(
                      f.percentFromFraction(score),
                      style: context.texts.bodySmall
                          ?.copyWith(color: p.onSurfaceMuted),
                    ),
                  ],
                ),
              ),
          ],
          if (item.resolved) ...[
            const Divider(),
            Text(
              item.resolutionDiseaseName ?? l.expertNeedsRetake,
              style: context.texts.titleSmall,
            ),
            if (item.note != null)
              Text(item.note!, style: context.texts.bodySmall),
          ] else ...[
            const SizedBox(height: Space.xs),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l.expertConfirmDisease,
                    icon: Icons.check_circle_rounded,
                    onPressed: () => _resolve(context, ref),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Space.xs),
            AppButton(
              label: l.expertNeedsRetake,
              tone: AppButtonTone.secondary,
              icon: Icons.photo_camera_rounded,
              onPressed: () => _needsRetake(context, ref),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _resolve(BuildContext context, WidgetRef ref) async {
    final saved = await showStaffSheet<bool>(
      context,
      title: AppL10n.of(context).expertConfirmDisease,
      child: _ResolveSheet(item: item),
    );
    if (saved == true) ref.invalidate(expertReviewsProvider);
  }

  Future<void> _needsRetake(BuildContext context, WidgetRef ref) async {
    final l = AppL10n.of(context);
    final note = await askStaffReason(
      context,
      title: l.expertRetakeTitle,
      hint: l.expertRetakeHint,
      actionLabel: l.expertSend,
    );
    if (note == null) return;
    try {
      await ref
          .read(expertRepositoryProvider)
          .needsRetake(item.id, note: note);
      ref.invalidate(expertReviewsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.expertRequestSent)),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }
}


/// Picking the disease is the whole job, so the sheet lists the ones that grow
/// on this crop and nothing else, plus an optional note for the farmer.
class _ResolveSheet extends ConsumerStatefulWidget {
  const _ResolveSheet({required this.item});

  final ReviewCase item;

  @override
  ConsumerState<_ResolveSheet> createState() => _ResolveSheetState();
}

class _ResolveSheetState extends ConsumerState<_ResolveSheet> {
  final _note = TextEditingController();
  String? _diseaseId;
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final diseases = ref.watch(_diseasesForCropProvider(widget.item.crop));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        diseases.when(
          loading: () => const LoadingState(rows: 2, showHeader: false),
          error: (error, _) => ErrorState(
            body: staffErrorText(error, l),
            onRetry: () =>
                ref.invalidate(_diseasesForCropProvider(widget.item.crop)),
          ),
          data: (list) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.expertPickDisease,
                style: context.texts.labelMedium
                    ?.copyWith(color: context.palette.onSurfaceMuted),
              ),
              const SizedBox(height: Space.xs),
              Wrap(
                spacing: Space.xs,
                runSpacing: Space.xs,
                children: [
                  for (final disease in list)
                    ChoiceChip(
                      label: Text(
                        disease.isHealthy
                            ? '${disease.nameBn} (${l.expertHealthy})'
                            : disease.nameBn,
                      ),
                      selected: _diseaseId == disease.id,
                      showCheckmark: true,
                      onSelected: (_) =>
                          setState(() => _diseaseId = disease.id),
                    ),
                ],
              ),
            ],
          ),
        ),
        StaffField(
          controller: _note,
          label: l.expertNote,
          maxLines: 3,
        ),
        AppButton(
          label: l.expertConfirmDisease,
          isLoading: _saving,
          isEnabled: _diseaseId != null,
          onPressed: _save,
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

  Future<void> _save() async {
    final id = _diseaseId;
    if (id == null) return;
    final l = AppL10n.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(expertRepositoryProvider).resolve(
            widget.item.id,
            diseaseId: id,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
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

/// The Krishi Barta pipeline the expert owns: AI-drafted items to check, then
/// publish (with the urgent flag) or reject with a reason (FR-44).
class ExpertNewsScreen extends ConsumerStatefulWidget {
  const ExpertNewsScreen({super.key});

  @override
  ConsumerState<ExpertNewsScreen> createState() => _ExpertNewsScreenState();
}

class _ExpertNewsScreenState extends ConsumerState<ExpertNewsScreen> {
  int _filter = 0;

  static const List<DraftStatus?> _filters = [
    null,
    DraftStatus.needsWriting,
    DraftStatus.draft,
    DraftStatus.published,
    DraftStatus.rejected,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final async = ref.watch(expertNewsProvider);

    return AppScreen(
      title: l.navNews,
      showBack: false,
      header: StaffTabHeader(
        title: l.navNews,
        subtitle: l.expertNewsSubtitle,
        icon: Icons.campaign_rounded,
        showBack: true,
        actions: [
          IconButton(
            tooltip: l.expertAddManual,
            onPressed: _addManual,
            icon: const Icon(Icons.add_rounded),
          ),
          IconButton(
            tooltip: l.expertSuggestSource,
            onPressed: _suggestSource,
            icon: const Icon(Icons.rss_feed_rounded),
          ),
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(expertNewsProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: async.when(
        loading: () => const LoadingState(rows: 4),
        error: (error, _) => ErrorState(
          body: staffErrorText(error, l),
          onRetry: () => ref.invalidate(expertNewsProvider),
        ),
        data: (drafts) {
          final wanted = _filters[_filter];
          final shown = wanted == null
              ? drafts
              : drafts.where((d) => d.status == wanted).toList(growable: false);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OpsFilters(
                labels: [
                  l.filterAll,
                  l.draftNeedsWriting,
                  l.draftInProgress,
                  l.draftPublished,
                  l.draftRejected,
                ],
                index: _filter,
                onChanged: (i) => setState(() => _filter = i),
              ),
              const SizedBox(height: Space.md),
              if (shown.isEmpty)
                EmptyState(
                  icon: Icons.campaign_rounded,
                  title: l.expertNewsEmpty,
                  body: l.expertNewsEmptyBody,
                )
              else
                for (final draft in shown)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Space.xs),
                    child: _DraftCard(draft: draft),
                  ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addManual() async {
    final l = AppL10n.of(context);
    final saved = await showStaffSheet<bool>(
      context,
      title: l.expertAddManual,
      child: const _ManualNewsSheet(),
    );
    if (saved == true && mounted) {
      ref.invalidate(expertNewsProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.expertDraftCreated)),
      );
    }
  }

  Future<void> _suggestSource() async {
    final l = AppL10n.of(context);
    final saved = await showStaffSheet<bool>(
      context,
      title: l.expertSuggestSource,
      child: const _SuggestSourceSheet(),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.expertSourceSuggested)),
      );
    }
  }
}

class _DraftCard extends ConsumerWidget {
  const _DraftCard({required this.draft});

  final NewsDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: Space.xs,
            runSpacing: Space.xxs,
            children: [
              OpsPill(label: l.draftStatus(draft.status)),
              if (draft.urgent) OpsPill(label: l.expertUrgent, tone: OpsTone.danger),
            ],
          ),
          const SizedBox(height: Space.xs),
          Text(draft.titleBn, style: context.texts.titleSmall),
          const SizedBox(height: Space.xxs),
          Text(
            draft.summaryBn,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall,
          ),
          const SizedBox(height: Space.xxs),
          Text(
            '${draft.sourceName} · ${f.relative(draft.updatedAt)}',
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
          if (draft.aiTags.isNotEmpty) ...[
            const SizedBox(height: Space.xs),
            Wrap(
              spacing: Space.xs,
              runSpacing: Space.xxs,
              children: [
                const AiBadge(),
                for (final tag in draft.aiTags)
                  OpsPill(label: tag, tone: OpsTone.neutral),
              ],
            ),
          ],
          if (draft.status == DraftStatus.rejected && draft.rejectReason != null)
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: Text(
                draft.rejectReason!,
                style: context.texts.bodySmall?.copyWith(color: p.error),
              ),
            ),
          const SizedBox(height: Space.xs),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l.actionEdit,
                  tone: AppButtonTone.secondary,
                  icon: Icons.edit_rounded,
                  onPressed: () async {
                    final saved = await showStaffSheet<bool>(
                      context,
                      title: l.expertEditNews,
                      child: _NewsSheet(draft: draft),
                    );
                    if (saved == true) ref.invalidate(expertNewsProvider);
                  },
                ),
              ),
            ],
          ),
          if (draft.status != DraftStatus.published) ...[
            const SizedBox(height: Space.xs),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: l.expertPublish,
                    icon: Icons.publish_rounded,
                    onPressed: () => _publish(context, ref),
                  ),
                ),
                const SizedBox(width: Space.xs),
                AppButton(
                  label: l.expertReject,
                  tone: AppButtonTone.danger,
                  expand: false,
                  onPressed: () => _reject(context, ref),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Publishing is the one irreversible step here, so the urgent flag is asked
  /// for explicitly instead of being a switch that could be missed.
  Future<void> _publish(BuildContext context, WidgetRef ref) async {
    final l = AppL10n.of(context);
    final urgent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.expertPublishTitle),
        content: Text(l.expertPublishBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l.actionCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.expertPublish),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.expertPublishUrgent),
          ),
        ],
      ),
    );
    if (urgent == null) return;

    try {
      await ref.read(expertRepositoryProvider).approveNews(draft.id, urgent: urgent);
      ref.invalidate(expertNewsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.expertPublished)),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final l = AppL10n.of(context);
    final reason = await askStaffReason(
      context,
      title: l.expertRejectTitle,
      hint: l.expertRejectHint,
      actionLabel: l.expertReject,
    );
    if (reason == null) return;
    try {
      await ref.read(expertRepositoryProvider).rejectNews(draft.id, reason: reason);
      ref.invalidate(expertNewsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.expertRejected)),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }
}

class _NewsSheet extends ConsumerStatefulWidget {
  const _NewsSheet({required this.draft});

  final NewsDraft draft;

  @override
  ConsumerState<_NewsSheet> createState() => _NewsSheetState();
}

class _NewsSheetState extends ConsumerState<_NewsSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title =
      TextEditingController(text: widget.draft.titleBn);
  late final TextEditingController _summary =
      TextEditingController(text: widget.draft.summaryBn);
  late final TextEditingController _symptoms =
      TextEditingController(text: widget.draft.symptomsBn ?? '');
  late final TextEditingController _action =
      TextEditingController(text: widget.draft.advisedActionBn ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _symptoms.dispose();
    _action.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          StaffField(
            controller: _title,
            label: l.expertNewsTitle,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          StaffField(
            controller: _summary,
            label: l.expertNewsSummary,
            maxLines: 4,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          StaffField(
            controller: _symptoms,
            label: l.expertNewsSymptoms,
            maxLines: 3,
          ),
          StaffField(
            controller: _action,
            label: l.expertNewsAction,
            maxLines: 3,
          ),
          AppCard(
            padding: const EdgeInsets.all(Space.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.expertNewsSource, style: context.texts.titleSmall),
                Text(
                  widget.draft.sourceName,
                  style: context.texts.bodySmall,
                ),
                if (widget.draft.sourceExcerpt != null)
                  Text(
                    widget.draft.sourceExcerpt!,
                    style: context.texts.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.sm),
          AppButton(
            label: l.actionSave,
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
      await ref.read(expertRepositoryProvider).saveDraft(
            widget.draft.copyWith(
              titleBn: _title.text.trim(),
              summaryBn: _summary.text.trim(),
              symptomsBn: _symptoms.text.trim(),
              advisedActionBn: _action.text.trim(),
            ),
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

/// The expert's own news item, per API_SPEC §9 `POST /expert/news`.
class _ManualNewsSheet extends ConsumerStatefulWidget {
  const _ManualNewsSheet();

  @override
  ConsumerState<_ManualNewsSheet> createState() => _ManualNewsSheetState();
}

class _ManualNewsSheetState extends ConsumerState<_ManualNewsSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _action = TextEditingController();
  NewsCategory _category = NewsCategory.disease;
  CropType _crop = CropType.rice;
  Severity _severity = Severity.medium;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _action.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          StaffField(
            controller: _title,
            label: l.expertNewsTitle,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          StaffField(
            controller: _summary,
            label: l.expertNewsSummary,
            maxLines: 4,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          StaffField(
            controller: _action,
            label: l.expertNewsAction,
            maxLines: 3,
          ),
          StaffChoice<CropType>(
            label: l.expertNewsCrop,
            selected: _crop,
            options: [
              for (final crop in CropType.values)
                (value: crop, label: crop.label(l)),
            ],
            onChanged: (value) => setState(() => _crop = value),
          ),
          StaffChoice<NewsCategory>(
            label: l.expertNewsCategory,
            selected: _category,
            options: [
              for (final category in NewsCategory.values)
                (value: category, label: category.label(l)),
            ],
            onChanged: (value) => setState(() => _category = value),
          ),
          StaffChoice<Severity>(
            label: l.expertNewsSeverity,
            selected: _severity,
            options: [
              for (final severity in Severity.values)
                (value: severity, label: severity.label(l)),
            ],
            onChanged: (value) => setState(() => _severity = value),
          ),
          AppButton(
            label: l.expertSaveDraft,
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
      await ref.read(expertRepositoryProvider).addManualNews(
            title: _title.text.trim(),
            summary: _summary.text.trim(),
            category: _category,
            crop: _crop,
            severity: _severity,
            advisedAction: _action.text.trim(),
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

class _SuggestSourceSheet extends ConsumerStatefulWidget {
  const _SuggestSourceSheet();

  @override
  ConsumerState<_SuggestSourceSheet> createState() =>
      _SuggestSourceSheetState();
}

class _SuggestSourceSheetState extends ConsumerState<_SuggestSourceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _url = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          StaffField(
            controller: _name,
            label: l.expertSourceName,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          StaffField(
            controller: _url,
            label: l.expertSourceUrl,
            keyboardType: TextInputType.url,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          StaffField(
            controller: _note,
            label: l.expertSourceNote,
            maxLines: 2,
          ),
          AppButton(
            label: l.expertSendSuggestion,
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
      await ref.read(expertRepositoryProvider).suggestSource(
            name: _name.text.trim(),
            url: _url.text.trim(),
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
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

/// Treatment knowledge base. Saving bumps the version and queues a reindex; the
/// screen says so rather than pretending the change is live immediately.
class ExpertKnowledgeScreen extends ConsumerStatefulWidget {
  const ExpertKnowledgeScreen({super.key});

  @override
  ConsumerState<ExpertKnowledgeScreen> createState() =>
      _ExpertKnowledgeScreenState();
}

class _ExpertKnowledgeScreenState extends ConsumerState<ExpertKnowledgeScreen> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final async = ref.watch(expertKnowledgeProvider(_query));

    return AppScreen(
      title: l.navKnowledge,
      showBack: false,
      header: StaffTabHeader(
        title: l.navKnowledge,
        subtitle: l.expertKnowledgeSubtitle,
        icon: Icons.menu_book_rounded,
        showBack: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) => setState(() => _query = value.trim()),
            decoration: InputDecoration(
              labelText: l.expertKnowledgeSearch,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: Space.md),
          async.when(
            loading: () => const LoadingState(rows: 3),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(expertKnowledgeProvider(_query)),
            ),
            data: (entries) {
              if (entries.isEmpty) {
                return EmptyState(
                  icon: Icons.menu_book_rounded,
                  title: l.expertKnowledgeEmpty,
                  body: l.expertKnowledgeEmptyBody,
                );
              }
              final f = AppFormat.of(context);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final entry in entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.diseaseName,
                              style: context.texts.titleSmall,
                            ),
                            Text(
                              '${entry.crop?.label(l) ?? ''} · '
                              '${l.expertKnowledgeVersion(f.number(entry.version))} · '
                              '${f.shortDate(entry.updatedAt)}',
                              style: context.texts.bodySmall,
                            ),
                            const SizedBox(height: Space.xxs),
                            Text(
                              entry.protocolBn,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: context.texts.bodySmall,
                            ),
                            const SizedBox(height: Space.xs),
                            AppButton(
                              label: l.actionEdit,
                              tone: AppButtonTone.secondary,
                              icon: Icons.edit_rounded,
                              onPressed: () => _edit(entry),
                            ),
                          ],
                        ),
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

  Future<void> _edit(KnowledgeEntry entry) async {
    final l = AppL10n.of(context);
    final saved = await showStaffSheet<bool>(
      context,
      title: l.expertKnowledgeEditTitle,
      child: _KnowledgeSheet(entry: entry),
    );
    if (saved == true && mounted) {
      ref.invalidate(expertKnowledgeProvider(_query));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.expertKnowledgeReindex)),
      );
    }
  }
}

class _KnowledgeSheet extends ConsumerStatefulWidget {
  const _KnowledgeSheet({required this.entry});

  final KnowledgeEntry entry;

  @override
  ConsumerState<_KnowledgeSheet> createState() => _KnowledgeSheetState();
}

class _KnowledgeSheetState extends ConsumerState<_KnowledgeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _protocol =
      TextEditingController(text: widget.entry.protocolBn);
  late final TextEditingController _source =
      TextEditingController(text: widget.entry.source);
  late final TextEditingController _safety =
      TextEditingController(text: widget.entry.safetyNoteBn);
  bool _saving = false;

  @override
  void dispose() {
    _protocol.dispose();
    _source.dispose();
    _safety.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.entry.diseaseName,
            style: context.texts.titleSmall,
          ),
          const SizedBox(height: Space.sm),
          StaffField(
            controller: _protocol,
            label: l.expertKnowledgeProtocol,
            maxLines: 6,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          StaffField(
            controller: _source,
            label: l.expertKnowledgeSource,
            maxLines: 2,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          StaffField(
            controller: _safety,
            label: l.expertKnowledgeSafety,
            maxLines: 3,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          AppButton(
            label: l.actionSave,
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
      await ref.read(expertRepositoryProvider).saveKnowledge(
            diseaseId: widget.entry.diseaseId,
            protocolBn: _protocol.text.trim(),
            source: _source.text.trim(),
            safetyNoteBn: _safety.text.trim(),
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
