import 'package:agrisense/core/providers/session_provider.dart';
import 'package:agrisense/core/providers/settings_provider.dart';
import 'package:agrisense/core/theme/app_theme.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:agrisense/data/models/user.dart';
import 'package:agrisense/features/admin/admin_home_screen.dart';
import 'package:agrisense/features/admin/admin_screens.dart';
import 'package:agrisense/features/expert/expert_home_screen.dart';
import 'package:agrisense/features/staff/staff_profile_screen.dart';
import 'package:agrisense/features/vendor/vendor_home_screen.dart';
import 'package:agrisense/features/vendor/vendor_screens.dart';
import 'package:agrisense/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The three consoles are chart-and-card heavy, which is exactly where a 320dp
/// phone with Bangla at 1.3x starts overflowing. These tests are the same rule
/// the farmer screens are held to, applied to the staff panels.
const _narrow = Size(320, 720);
const _phone = Size(412, 915);

const _vendor = AppUser(
  id: 'usr-0002',
  name: 'রহিম মিয়া',
  mobile: '01711000002',
  role: Role.vendor,
  status: AccountStatus.active,
  district: 'গাজীপুর',
  vendor: VendorProfile(
    shopName: 'রহিম কৃষি ভাণ্ডার',
    verificationStatus: 'verified',
    rating: 4.6,
  ),
);

const _expert = AppUser(
  id: 'usr-0003',
  name: 'ড. মাহবুবুর রহমান',
  mobile: '01711000003',
  role: Role.expert,
  status: AccountStatus.active,
  district: 'ঢাকা',
  expert: ExpertProfile(
    specialization: 'ধান ও সবজির রোগ',
    certification: 'BARI-2019-4471',
  ),
);

const _admin = AppUser(
  id: 'usr-0004',
  name: 'প্ল্যাটফর্ম অ্যাডমিন',
  mobile: '01711000004',
  role: Role.admin,
  status: AccountStatus.active,
  district: 'ঢাকা',
);

late SharedPreferences _prefs;

Widget _host(Widget screen, AppUser user) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(_prefs),
      currentUserProvider.overrideWithValue(user),
    ],
    child: MaterialApp(
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
    ),
  );
}

Future<List<String>> _pumpAndCollect(
  WidgetTester tester,
  Widget screen,
  AppUser user,
) async {
  final original = FlutterError.onError;
  final errors = <String>[];
  FlutterError.onError = (details) {
    if (details.exceptionAsString().contains('overflowed')) {
      errors.add(details.toString());
    } else {
      original?.call(details);
    }
  };

  await tester.pumpWidget(_host(screen, user));
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 400));
  }

  FlutterError.onError = original;
  return errors;
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('bn', null);
    await initializeDateFormatting('en', null);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'settings.language': 'bn',
      'settings.language_chosen': true,
      'settings.consent_given': true,
    });
    _prefs = await SharedPreferences.getInstance();
  });

  final screens = <String, (AppUser, Widget Function())>{
    'vendor home': (_vendor, () => const VendorHomeScreen()),
    'vendor products': (_vendor, () => const VendorProductsScreen()),
    'vendor orders': (_vendor, () => const VendorOrdersScreen()),
    'vendor business': (_vendor, () => const VendorBusinessScreen()),
    'expert home': (_expert, () => const ExpertHomeScreen()),
    'expert questions': (_expert, () => const ExpertQuestionsScreen()),
    'expert studio': (_expert, () => const ExpertStudioScreen()),
    'expert consultations':
        (_expert, () => const ExpertConsultationsScreen()),
    'admin overview': (_admin, () => const AdminHomeScreen()),
    'admin approvals': (_admin, () => const AdminApprovalsScreen()),
    'admin users': (_admin, () => const AdminUsersScreen()),
    'admin monitor': (_admin, () => const AdminMonitorScreen()),
    'admin system': (_admin, () => const AdminSystemScreen()),
    'staff profile': (_admin, () => const StaffProfileScreen()),
  };

  for (final scale in [1.0, 1.3]) {
    for (final size in [_narrow, _phone]) {
      for (final entry in screens.entries) {
        testWidgets(
          '${entry.key} lays out at ${size.width.toInt()}dp x$scale',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(
              tester.platformDispatcher.clearTextScaleFactorTestValue,
            );

            final (user, build) = entry.value;
            final errors = await _pumpAndCollect(tester, build(), user);
            expect(
              errors,
              isEmpty,
              reason: '${entry.key} overflowed:\n${errors.join('\n')}',
            );
          },
        );
      }
    }
  }
}
