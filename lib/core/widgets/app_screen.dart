import 'package:flutter/material.dart';

import '../theme/app_metrics.dart';
import '../theme/app_theme.dart';
import 'ambience.dart';

/// Standard screen chrome.
///
/// Every screen in the app is built on this so the safe-area handling, title
/// treatment, scroll physics and bottom padding are identical everywhere.
/// [bottomInset] exists because the farmer shell floats a 72dp mic plus a bottom
/// nav over the page, and content that scrolls under them is unreachable.
class AppScreen extends StatefulWidget {
  const AppScreen({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.leading,
    this.scrollable = true,
    this.padHorizontal = true,
    this.bottomInset = 0,
    this.bottomBar,
    this.bottomNav,
    this.fab,
    this.banner,
    this.header,
    this.showBack = true,
    this.ambience,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? leading;
  final bool scrollable;
  final bool padHorizontal;
  final double bottomInset;

  /// A pinned action bar, e.g. the confirm button on the order sheet.
  final Widget? bottomBar;

  /// The role's navigation bar, when this screen is one of its tabs.
  final Widget? bottomNav;

  /// The farmer's global microphone. Only the farmer shell passes one.
  final Widget? fab;

  /// Rendered above the scroll view and full-bleed, e.g. [OfflineBanner].
  final Widget? banner;

  /// Replaces the AppBar entirely. The staff tabs use a painted header here so
  /// their console does not fall back to the plain white app bar.
  final Widget? header;

  final bool showBack;

  /// The page's own decorative motion. Every tab passes the mood that matches
  /// what the screen is about, so the অ্যানিমেশন mode is not only a Home
  /// feature. Null paints nothing.
  final AmbienceMood? ambience;

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final canPop = Navigator.of(context).canPop();

    // The nav is a fixed, opaque bar, so the Scaffold already ends the body
    // above it. What still floats over the page is the 72dp mic, docked on the
    // bar's edge — this is the inset that keeps the last row of a list
    // reachable instead of permanently under the microphone.
    final fabInset = widget.fab == null ? 0.0 : 64.0;

    final body = Column(
      children: [
        ?widget.header,
        ?widget.banner,
        Expanded(
          child: widget.scrollable
              ? SingleChildScrollView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    widget.padHorizontal ? Space.md : 0,
                    Space.xs,
                    widget.padHorizontal ? Space.md : 0,
                    Space.md + widget.bottomInset + fabInset,
                  ),
                  child: widget.child,
                )
              : Padding(
                  padding: EdgeInsets.fromLTRB(
                    widget.padHorizontal ? Space.md : 0,
                    0,
                    widget.padHorizontal ? Space.md : 0,
                    widget.bottomInset + fabInset,
                  ),
                  child: widget.child,
                ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: p.background,
      appBar: widget.header != null
          ? null
          : AppBar(
              title: Text(widget.title),
              automaticallyImplyLeading: false,
              leading: widget.leading ??
                  (widget.showBack && canPop
                      ? IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                          tooltip:
                              MaterialLocalizations.of(context).backButtonTooltip,
                        )
                      : null),
              actions: widget.actions,
            ),
      body: widget.ambience == null
          ? PageReveal(child: body)
          : AmbientBackdrop(
              mood: widget.ambience!,
              scrollController: widget.scrollable ? _scroll : null,
              child: PageReveal(child: body),
            ),
      bottomNavigationBar: widget.bottomNav ??
          (widget.bottomBar == null
              ? null
              : SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(Space.md),
                    child: widget.bottomBar,
                  ),
                )),
      floatingActionButton: widget.fab,
      floatingActionButtonLocation:
          widget.fab == null ? null : FloatingActionButtonLocation.centerDocked,
    );
  }
}
