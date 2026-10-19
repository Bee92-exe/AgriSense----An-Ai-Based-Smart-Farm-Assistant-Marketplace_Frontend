import 'package:agrisense/core/providers/session_provider.dart';
import 'package:agrisense/core/providers/settings_provider.dart';
import 'package:agrisense/core/theme/app_theme.dart';
import 'package:agrisense/core/widgets/app_card.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:agrisense/data/models/user.dart';
import 'package:agrisense/features/admin/admin_providers.dart';
import 'package:agrisense/features/admin/admin_screens.dart';
import 'package:agrisense/features/expert/expert_screens.dart';
import 'package:agrisense/features/vendor/vendor_screens.dart';
import 'package:agrisense/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The demo vendor account the mock desk belongs to (`01711000002`).
const _vendorUser = AppUser(
  id: 'usr-0002',
  name: 'রহিম মিয়া',
  mobile: '01711000002',
  role: Role.vendor,
  status: AccountStatus.active,
  district: 'গাজীপুর',
  vendor: VendorProfile(
    shopName: 'রহিম কৃষি ভাণ্ডার',
    verificationStatus: 'verified',
  ),
);

Widget _host(Widget screen) => MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      locale: const Locale('bn'),
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppL10n.supportedLocales,
      home: screen,
    );

/// The mocks answer in 300–1500 ms, so every assertion waits out a few of those
/// instead of assuming the first frame holds data.
Future<void> _settle(WidgetTester tester, {int steps = 12}) async {
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }
}

/// The card that carries [text], so a tap lands on the right product, order or
/// vendor when the list holds several.
Finder _cardWith(String text) => find.ancestor(
      of: find.text(text),
      matching: find.byType(AppCard),
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('bn', null);
    await initializeDateFormatting('en', null);
  });

  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'settings.language': 'bn',
      'settings.language_chosen': true,
      'settings.consent_given': true,
    });
    prefs = await SharedPreferences.getInstance();
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        currentUserProvider.overrideWithValue(_vendorUser),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: _host(screen)),
    );
    await _settle(tester);
  }

  testWidgets('a vendor raises stock and the desk records the new number',
      (tester) async {
    await pumpScreen(tester, const VendorProductsScreen());

    const product = 'ট্রাইসাইক্লাজল ৭৫% ডব্লিউপি';
    expect(find.text(product), findsOneWidget);
    expect(
      find.descendant(of: _cardWith(product), matching: find.text('স্টক ২৪')),
      findsOneWidget,
    );

    await tester.tap(
      find.descendant(
        of: _cardWith(product),
        matching: find.byTooltip('একটি বাড়ান'),
      ),
    );
    await _settle(tester);

    // The number the vendor sees and the number the desk holds have to be the
    // same one, not a locally-patched display value. The provider is read after
    // the screen's own invalidation has been pumped, so this is the refetched
    // state and not the previous one.
    final desk = container.read(vendorDeskProvider).value!;
    final saved = desk.products.firstWhere((p) => p.id == 'prd-1');
    expect(saved.stock, 25);
    expect(
      find.descendant(of: _cardWith(product), matching: find.text('স্টক ২৫')),
      findsOneWidget,
    );
  });

  testWidgets('a vendor creates a listing through the product sheet',
      (tester) async {
    await pumpScreen(tester, const VendorProductsScreen());

    await tester.tap(find.byTooltip('নতুন পণ্য যোগ করুন'));
    await _settle(tester, steps: 4);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'পণ্যের নাম'),
      'নতুন ধান বীজ',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'দাম (টাকা)'),
      '950',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'স্টকে পরিমাণ'),
      '7',
    );
    // A seed listing, so the category the vendor picked is what gets stored.
    await tester.tap(find.text('বীজ'));
    await _settle(tester, steps: 2);

    await tester.tap(find.text('সংরক্ষণ করুন'));
    await _settle(tester);

    final desk = container.read(vendorDeskProvider).value!;
    final created = desk.products.firstWhere((p) => p.name == 'নতুন ধান বীজ');
    expect(created.price, 950);
    expect(created.stock, 7);
    expect(created.category, 'seed');
    expect(find.text('নতুন ধান বীজ'), findsOneWidget);
  });

  testWidgets('a vendor accepts a pending order, and only that transition',
      (tester) async {
    await pumpScreen(tester, const VendorOrdersScreen());

    const orderNo = 'AS-2026-000145';
    expect(find.text(orderNo), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: _cardWith(orderNo),
        matching: find.text('অর্ডার নিশ্চিত করুন'),
      ),
    );
    await _settle(tester);

    final desk = container.read(vendorDeskProvider).value!;
    final order = desk.orders.firstWhere((o) => o.order.orderNo == orderNo);
    expect(order.order.status, OrderStatus.confirmed);
    // The only step left from `confirmed` is shipping — accepting must not skip
    // it, and shipping must not become reachable earlier.
    expect(order.nextActions, [OrderStatus.shipped]);
  });

  testWidgets('an expert resolves a low-confidence case out of the queue',
      (tester) async {
    await pumpScreen(tester, const ExpertReviewsScreen());

    // The AI's own guess is visible here and labelled as machine output; the
    // farmer never sees it.
    expect(find.text('AI-এর অনুমান (কৃষক দেখেন না)'), findsWidgets);
    expect(find.text('সেলিনা বেগম'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: _cardWith('সেলিনা বেগম'),
        matching: find.text('রোগ নিশ্চিত করুন'),
      ),
    );
    await _settle(tester, steps: 5);

    // Scoped to the sheet: the review filter row is built from the same
    // ChoiceChip widget, so an unscoped finder would tap a filter instead.
    final sheetChips = find.descendant(
      of: find.byType(BottomSheet),
      matching: find.byType(ChoiceChip),
    );
    await tester.tap(sheetChips.first);
    await _settle(tester, steps: 2);

    // The sheet's form is taller than the viewport, so its confirm button has to
    // be scrolled to the way an expert would.
    // `.last`: the sheet carries the same words as its own title, and it is the
    // button at the end of the form that confirms.
    final confirm = find
        .descendant(
          of: find.byType(BottomSheet),
          matching: find.text('রোগ নিশ্চিত করুন'),
        )
        .last;
    await tester.ensureVisible(confirm);
    await _settle(tester, steps: 2);
    await tester.tap(confirm);
    await _settle(tester);

    final cases = container.read(expertReviewsProvider).value!;
    final resolved = cases.firstWhere((c) => c.id == 'rev-1');
    expect(resolved.resolved, isTrue);
    expect(resolved.resolutionDiseaseName, isNotNull);
    expect(
      cases.where((c) => !c.resolved).length,
      4,
      reason: 'the case has to leave the pending queue',
    );
  });

  testWidgets('an admin verifies a vendor, and a suspension keeps its reason',
      (tester) async {
    await pumpScreen(tester, const AdminVendorsScreen());

    const pendingShop = 'নতুন কৃষক ভান্ডার';
    expect(find.text(pendingShop), findsOneWidget);

    final before = container.read(adminVendorsProvider(null)).value!;
    final pendingBefore = before.where((v) => v.isPending).length;

    await tester.tap(
      find.descendant(
        of: _cardWith(pendingShop),
        matching: find.text('যাচাই করুন'),
      ),
    );
    await _settle(tester);

    final after = container.read(adminVendorsProvider(null)).value!;
    final approved = after.firstWhere((v) => v.shopName == pendingShop);
    expect(approved.isVerified, isTrue);
    expect(after.where((v) => v.isPending).length, pendingBefore - 1);

    // Suspending an older vendor has to store the reason the admin typed, since
    // that sentence is what the vendor is later shown.
    final target = after
        .firstWhere((v) => v.isVerified && v.shopName != pendingShop)
        .shopName;
    const reason = 'মেয়াদোত্তীর্ণ ওষুধের অভিযোগ পাওয়া গেছে।';

    final suspendButton = find.descendant(
      of: _cardWith(target),
      matching: find.text('স্থগিত করুন'),
    );
    await tester.ensureVisible(suspendButton);
    await _settle(tester, steps: 2);
    await tester.tap(suspendButton);
    await _settle(tester, steps: 3);

    await tester.enterText(find.byType(TextField).last, reason);
    await tester.tap(find.text('স্থগিত করুন').last);
    await _settle(tester);

    final suspended = container
        .read(adminVendorsProvider(null))
        .value!
        .firstWhere((v) => v.shopName == target);
    expect(suspended.status, 'suspended');
    expect(suspended.reason, reason);
  });
}
