import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/labels.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_screen.dart';
import '../../core/widgets/states.dart';
import '../../data/models/ops.dart';
import '../../data/providers.dart';
import '../../l10n/app_localizations.dart';
import '../staff/staff_design.dart';
import '../staff/staff_widgets.dart';
import 'admin_providers.dart';

/// News sources, the collection schedule and the log view (FR-41, FR-50).
///
/// Sources and the schedule share a screen because they are one job: what the
/// collector reads and how often it runs. Splitting them would mean crossing a
/// tab to answer "is the collector healthy?".
class AdminSourcesScreen extends ConsumerWidget {
  const AdminSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppL10n.of(context);
    final sources = ref.watch(adminSourcesProvider);

    return AppScreen(
      title: l.navSources,
      showBack: false,
      header: StaffTabHeader(
        title: l.navSources,
        subtitle: l.adminSourcesSubtitle,
        icon: Icons.rss_feed_rounded,
        showBack: true,
        actions: [
          IconButton(
            tooltip: l.adminAddSource,
            onPressed: () => _openEditor(context, ref, null),
            icon: const Icon(Icons.add_rounded),
          ),
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () {
              ref.invalidate(adminSourcesProvider);
              ref.invalidate(adminScheduleProvider);
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _ScheduleCard(),
          const SizedBox(height: Space.lg),
          sources.when(
            loading: () => const LoadingState(rows: 3),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(adminSourcesProvider),
            ),
            data: (list) {
              if (list.isEmpty) {
                return EmptyState(
                  icon: Icons.rss_feed_rounded,
                  title: l.adminSourceEmpty,
                  body: l.adminSourceEmptyBody,
                  actionLabel: l.adminAddSource,
                  onAction: () => _openEditor(context, ref, null),
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final source in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: _SourceCard(source: source),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref,
    ManagedNewsSource? source,
  ) async {
    final l = AppL10n.of(context);
    final saved = await showStaffSheet<bool>(
      context,
      title: source == null ? l.adminAddSource : l.adminEditSource,
      child: _SourceSheet(source: source),
    );
    if (saved == true) {
      ref.invalidate(adminSourcesProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.adminSourceSaved)),
        );
      }
    }
  }
}

class _ScheduleCard extends ConsumerStatefulWidget {
  const _ScheduleCard();

  @override
  ConsumerState<_ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends ConsumerState<_ScheduleCard> {
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final async = ref.watch(adminScheduleProvider);

    return AppCard(
      child: async.when(
        loading: () => const LoadingState(rows: 2, showHeader: false),
        error: (error, _) => ErrorState(
          body: staffErrorText(error, l),
          onRetry: () => ref.invalidate(adminScheduleProvider),
        ),
        data: (schedule) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.adminScheduleTitle, style: context.texts.titleSmall),
            const SizedBox(height: Space.xs),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: schedule.enabled,
              title: Text(l.adminScheduleEnabled),
              onChanged: (value) => _save(
                intervalHours: schedule.intervalHours,
                enabled: value,
              ),
            ),
            Row(
              children: [
                Text(
                  l.adminScheduleInterval(
                    f.number(schedule.intervalHours),
                  ),
                  style: context.texts.bodyMedium,
                ),
                const Spacer(),
                _StepButton(
                  icon: Icons.remove_rounded,
                  tooltip: l.adminIntervalDown,
                  onPressed: schedule.intervalHours > 1
                      ? () => _save(
                            intervalHours: schedule.intervalHours - 1,
                            enabled: schedule.enabled,
                          )
                      : null,
                ),
                _StepButton(
                  icon: Icons.add_rounded,
                  tooltip: l.adminIntervalUp,
                  onPressed: schedule.intervalHours < 24
                      ? () => _save(
                            intervalHours: schedule.intervalHours + 1,
                            enabled: schedule.enabled,
                          )
                      : null,
                ),
              ],
            ),
            Text(
              l.adminScheduleNext(f.dateTime(schedule.nextRunAt)),
              style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
            ),
            const SizedBox(height: Space.sm),
            AppButton(
              label: l.adminRunNow,
              icon: Icons.play_arrow_rounded,
              isLoading: _running,
              onPressed: _runNow,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save({
    required int intervalHours,
    required bool enabled,
  }) async {
    final l = AppL10n.of(context);
    try {
      await ref
          .read(adminRepositoryProvider)
          .setSchedule(intervalHours: intervalHours, enabled: enabled);
      ref.invalidate(adminScheduleProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.adminScheduleSaved)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }

  Future<void> _runNow() async {
    final l = AppL10n.of(context);
    setState(() => _running = true);
    try {
      await ref.read(adminRepositoryProvider).runNow();
      // A run changes the sources' last-run state and adds a log line, so both
      // lists are refreshed rather than just the one on screen.
      ref.invalidate(adminSourcesProvider);
      ref.invalidate(adminLogsProvider);
      ref.invalidate(adminScheduleProvider);
      if (mounted) {
        setState(() => _running = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.adminRunDone)),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _running = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Sizes.minTapTarget,
      height: Sizes.minTapTarget,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _SourceCard extends ConsumerStatefulWidget {
  const _SourceCard({required this.source});

  final ManagedNewsSource source;

  @override
  ConsumerState<_SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends ConsumerState<_SourceCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final f = AppFormat.of(context);
    final p = context.palette;
    final source = widget.source;

    final (lastRun, tone) = switch ((source.lastRunAt, source.lastRunOk)) {
      (null, _) => (l.adminSourceNeverRun, OpsTone.neutral),
      (final at?, true) => (
          l.adminSourceLastRun(f.dateTime(at)),
          OpsTone.success,
        ),
      (final at?, _) => (
          '${l.adminSourceFailed} · ${f.dateTime(at)}',
          OpsTone.danger,
        ),
    };

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
              Text(source.name, style: context.texts.titleSmall),
              OpsPill(
                label: l.newsSourceType(source.type),
                tone: OpsTone.neutral,
              ),
            ],
          ),
          const SizedBox(height: Space.xxs),
          Text(
            source.url,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
          const SizedBox(height: Space.xxs),
          OpsPill(label: lastRun, tone: tone),
          if (source.lastError != null)
            Padding(
              padding: const EdgeInsets.only(top: Space.xxs),
              child: Text(
                source.lastError!,
                style: context.texts.bodySmall?.copyWith(color: p.error),
              ),
            ),
          const SizedBox(height: Space.xs),
          Row(
            children: [
              Expanded(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: source.active,
                  title: Text(
                    source.active ? l.adminSourceOn : l.adminSourceOff,
                    style: context.texts.bodyMedium,
                  ),
                  onChanged: _busy ? null : (value) => _toggle(value),
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton.icon(
                onPressed: () =>
                    AdminSourcesScreen._openEditor(context, ref, source),
                icon: const Icon(Icons.edit_rounded, size: Sizes.iconInline),
                label: Text(l.actionEdit),
              ),
              const Spacer(),
              IconButton(
                tooltip: l.actionDelete,
                onPressed: _busy ? null : _delete,
                icon: Icon(Icons.delete_outline_rounded, color: p.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(bool active) async {
    final l = AppL10n.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(adminRepositoryProvider).toggleSource(widget.source.id, active);
      ref.invalidate(adminSourcesProvider);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    final l = AppL10n.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l.adminSourceDeleteTitle),
        content: Text(l.adminSourceDeleteConfirm(widget.source.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminRepositoryProvider).removeSource(widget.source.id);
      ref.invalidate(adminSourcesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l.adminSourceRemoved)),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(staffErrorText(error, l))),
        );
      }
    }
  }
}

class _SourceSheet extends ConsumerStatefulWidget {
  const _SourceSheet({this.source});

  final ManagedNewsSource? source;

  @override
  ConsumerState<_SourceSheet> createState() => _SourceSheetState();
}

class _SourceSheetState extends ConsumerState<_SourceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name =
      TextEditingController(text: widget.source?.name ?? '');
  late final TextEditingController _url =
      TextEditingController(text: widget.source?.url ?? '');
  late String _type = widget.source?.type ?? 'government';
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _url.dispose();
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
            label: l.adminSourceName,
            validator: (v) =>
                (v ?? '').trim().isEmpty ? l.vendorFieldRequired : null,
          ),
          StaffField(
            controller: _url,
            label: l.adminSourceUrl,
            keyboardType: TextInputType.url,
            validator: (v) {
              final value = (v ?? '').trim();
              if (value.isEmpty) return l.vendorFieldRequired;
              if (!value.startsWith('http')) return l.adminSourceUrlInvalid;
              return null;
            },
          ),
          StaffChoice<String>(
            label: l.adminSourceType,
            selected: _type,
            options: [
              for (final type in kNewsSourceTypes)
                (value: type, label: l.newsSourceType(type)),
            ],
            onChanged: (value) => setState(() => _type = value),
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
      await ref.read(adminRepositoryProvider).saveSource(
            ManagedNewsSource(
              id: widget.source?.id ??
                  'src-new-${DateTime.now().millisecondsSinceEpoch}',
              name: _name.text.trim(),
              url: _url.text.trim(),
              type: _type,
              active: widget.source?.active ?? true,
              lastRunAt: widget.source?.lastRunAt,
              lastRunOk: widget.source?.lastRunOk,
              lastError: widget.source?.lastError,
              itemsLastRun: widget.source?.itemsLastRun ?? 0,
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

/// The log view: one line per event, filtered by family. Read-only by design —
/// an admin console that can edit its own log is not a log.
class AdminLogsScreen extends ConsumerStatefulWidget {
  const AdminLogsScreen({super.key});

  @override
  ConsumerState<AdminLogsScreen> createState() => _AdminLogsScreenState();
}

class _AdminLogsScreenState extends ConsumerState<AdminLogsScreen> {
  static const List<OpsLogType?> _types = [
    null,
    OpsLogType.collection,
    OpsLogType.system,
    OpsLogType.voice,
    OpsLogType.aiFallback,
    OpsLogType.audit,
  ];

  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final type = _types[_filter];
    final async = ref.watch(adminLogsProvider(type));

    return AppScreen(
      title: l.navLogs,
      showBack: false,
      header: StaffTabHeader(
        title: l.navLogs,
        subtitle: l.adminLogsSubtitle,
        icon: Icons.history_rounded,
        showBack: true,
        actions: [
          IconButton(
            tooltip: l.actionRetry,
            onPressed: () => ref.invalidate(adminLogsProvider(type)),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OpsFilters(
            labels: [
              l.filterAll,
              l.logTypeCollection,
              l.logTypeSystem,
              l.logTypeVoice,
              l.logTypeAiFallback,
              l.logTypeAudit,
            ],
            index: _filter,
            onChanged: (i) => setState(() => _filter = i),
          ),
          const SizedBox(height: Space.md),
          async.when(
            loading: () => const LoadingState(rows: 4),
            error: (error, _) => ErrorState(
              body: staffErrorText(error, l),
              onRetry: () => ref.invalidate(adminLogsProvider(type)),
            ),
            data: (logs) {
              if (logs.isEmpty) {
                return EmptyState(
                  icon: Icons.article_rounded,
                  title: l.adminLogsEmpty,
                  body: l.adminLogsEmptyBody,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final entry in logs)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Space.xs),
                      child: AppCard(
                        padding: const EdgeInsets.all(Space.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _iconFor(entry.type),
                              size: Sizes.iconInline,
                              color: context.palette.primary,
                            ),
                            const SizedBox(width: Space.xs),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.message,
                                    style: context.texts.bodySmall,
                                  ),
                                  Text(
                                    '${l.opsLogType(entry.type)} · '
                                    '${AppFormat.of(context).dateTime(entry.at)}',
                                    style: context.texts.bodySmall?.copyWith(
                                      color: context.palette.onSurfaceMuted,
                                    ),
                                  ),
                                ],
                              ),
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

  static IconData _iconFor(OpsLogType type) => switch (type) {
        OpsLogType.system => Icons.settings_rounded,
        OpsLogType.collection => Icons.rss_feed_rounded,
        OpsLogType.voice => Icons.mic_rounded,
        OpsLogType.aiFallback => Icons.auto_awesome_rounded,
        OpsLogType.audit => Icons.fact_check_rounded,
      };
}
