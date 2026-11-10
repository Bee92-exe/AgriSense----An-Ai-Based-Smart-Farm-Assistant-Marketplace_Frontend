import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../voice/speaker.dart';
import '../../l10n/app_localizations.dart';

/// Reads a block of text out loud, and stops when tapped again.
///
/// Used everywhere a farmer would otherwise have to read: news items, treatment
/// steps, the voice sheet's own replies. Hiding the control when the device
/// cannot speak is the honesty rule from the design system — a speaker icon that
/// produces silence is worse than no icon.
class ReadAloudButton extends ConsumerStatefulWidget {
  const ReadAloudButton({
    super.key,
    required this.text,
    this.label,
    this.autoPlay = false,
    this.tooltip,
  });

  /// Read verbatim. Callers pass the same words that are on screen.
  final String text;

  /// When set the control is a labelled button instead of a bare icon, for a
  /// section header where an icon alone would be ambiguous.
  final String? label;

  /// Speak as soon as this appears — used when the farmer has voice mode on.
  final bool autoPlay;

  final String? tooltip;

  @override
  ConsumerState<ReadAloudButton> createState() => _ReadAloudButtonState();
}

class _ReadAloudButtonState extends ConsumerState<ReadAloudButton> {
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPlay) {
      // After the first frame: speaking inside initState would touch the
      // platform channel while the tree is still being built.
      WidgetsBinding.instance.addPostFrameCallback((_) => _toggle());
    }
  }

  Future<void> _toggle() async {
    final speaker = ref.read(speakerProvider);
    if (!mounted) return;
    if (_speaking) {
      await speaker.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }
    setState(() => _speaking = true);
    await speaker.speak(
      widget.text,
      languageCode: Localizations.localeOf(context).languageCode,
    );
    if (mounted) setState(() => _speaking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.read(speakerProvider).isAvailable) return const SizedBox.shrink();
    final l = AppL10n.of(context);

    if (widget.label != null) {
      return TextButton.icon(
        onPressed: _toggle,
        icon: Icon(
          _speaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
        ),
        label: Text(widget.label!),
      );
    }

    return IconButton(
      onPressed: _toggle,
      tooltip: widget.tooltip ??
          (_speaking ? l.actionStopReading : l.actionReadAloud),
      icon: Icon(
        _speaking ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
      ),
    );
  }
}
