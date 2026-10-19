import 'package:flutter/material.dart';

import '../../core/theme/app_metrics.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/app_card.dart';

/// Colour families the staff screens use for status words.
///
/// Staff screens are dense, so status is always a short Bangla word in a pill
/// plus a colour — never colour alone, which is the same rule the farmer side
/// follows.
enum OpsTone { neutral, primary, warning, danger, success }

class OpsPill extends StatelessWidget {
  const OpsPill({super.key, required this.label, this.tone = OpsTone.neutral});

  final String label;
  final OpsTone tone;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    final (foreground, background) = switch (tone) {
      OpsTone.primary => (p.onPrimaryContainer, p.primaryContainer),
      OpsTone.warning => (p.onHarvestContainer, p.harvestContainer),
      OpsTone.danger => (p.error, p.errorContainer),
      OpsTone.success => (p.severityLow, p.severityLowContainer),
      OpsTone.neutral => (p.onSurfaceMuted, p.surfaceSunken),
    };

    // excludeSemantics: the pill already reads its own text, and without this a
    // screen reader announces every status twice.
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Space.xs, vertical: 4),
        decoration: BoxDecoration(
          color: background,
          borderRadius: Radii.chipAll,
          border: Border.all(color: foreground, width: p.borderWidth),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.texts.labelSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// One row of single-choice filters. Scrolls horizontally rather than wrapping
/// so the page does not jump when a long Bangla label is selected.
class OpsFilters extends StatelessWidget {
  const OpsFilters({
    super.key,
    required this.labels,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            ChoiceChip(
              label: Text(labels[i]),
              selected: i == index,
              onSelected: (_) => onChanged(i),
              showCheckmark: false,
            ),
            if (i != labels.length - 1) const SizedBox(width: Space.xs),
          ],
        ],
      ),
    );
  }
}

/// A number with its label, used across the three dashboards.
class OpsStat extends StatelessWidget {
  const OpsStat({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AppCard(
      padding: const EdgeInsets.all(Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: Sizes.iconInline, color: p.primary),
          const SizedBox(height: Space.xs),
          Text(value, style: context.texts.titleLarge),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.texts.bodySmall?.copyWith(color: p.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

/// Opens a staff form as a full-height scrollable sheet.
///
/// Every editor on the staff side uses this so keyboard insets and the sheet's
/// padding are handled once instead of eight times.
Future<T?> showStaffSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.palette.surface,
    shape: const RoundedRectangleBorder(borderRadius: Radii.sheet),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        left: Space.md,
        right: Space.md,
        top: Space.md,
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom + Space.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sheetContext.palette.outline,
                  borderRadius: Radii.chipAll,
                ),
              ),
            ),
            const SizedBox(height: Space.md),
            Text(title, style: context.texts.titleLarge),
            const SizedBox(height: Space.md),
            child,
          ],
        ),
      ),
    ),
  );
}

/// Asks for a short reason (reject a vendor, suspend a user, reject a news
/// draft). Returns null when the staff member backs out.
Future<String?> askStaffReason(
  BuildContext context, {
  required String title,
  required String hint,
  required String actionLabel,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLines: 3,
        decoration: InputDecoration(hintText: hint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(AppL10n.of(context).actionCancel),
        ),
        FilledButton(
          onPressed: () {
            final text = controller.text.trim();
            if (text.isEmpty) return;
            Navigator.of(dialogContext).pop(text);
          },
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}

/// Turns a repository failure into a Bangla sentence.
///
/// The mocks (and the API_SPEC error format) carry a `message_key` instead of a
/// message, so the app never shows a raw server string. Only the keys the staff
/// screens can actually provoke are mapped; anything else falls back to the
/// generic retry line rather than inventing a cause.
String staffErrorText(Object error, AppL10n l) {
  final key = error is ApiException ? error.messageKey : null;
  return switch (key) {
    'vendorBlockedBody' => l.vendorBlockedBody,
    'vendorInvalidTransition' => l.vendorInvalidTransition,
    _ => l.stateErrorBody,
  };
}

/// A labelled text field with the app's field rhythm. `maxLines` above one
/// gives a growable box for the long Bangla protocols and news bodies.
class StaffField extends StatelessWidget {
  const StaffField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        textInputAction: textInputAction,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}

/// Small labelled choice row used inside the sheets (product category, severity,
/// news category, source type). Kept as a wrap of chips so it reads as one
/// control with a label rather than a form field.
class StaffChoice<T> extends StatelessWidget {
  const StaffChoice({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final List<({T value, String label})> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(bottom: Space.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.texts.labelMedium?.copyWith(color: p.onSurfaceMuted),
          ),
          const SizedBox(height: Space.xs),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option.label),
                  selected: option.value == selected,
                  showCheckmark: false,
                  onSelected: (_) => onChanged(option.value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
