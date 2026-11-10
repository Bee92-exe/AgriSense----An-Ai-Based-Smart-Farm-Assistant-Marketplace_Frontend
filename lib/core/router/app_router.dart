import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/enums.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/pending_approval_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/assistant/assistant_screen.dart';
import '../../features/advisory/advisory_screen.dart';
import '../../features/auth/reset_password_screen.dart';
import '../../features/crop_advice/calendar_screen.dart';
import '../../features/crop_advice/crop_advice_screen.dart';
import '../../features/diagnosis/capture_screen.dart';
import '../../features/diagnosis/history_screen.dart';
import '../../features/diagnosis/result_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/market/market_screen.dart';
import '../../features/market/orders_screen.dart';
import '../../features/market/product_detail_screen.dart';
import '../../features/news/news_detail_screen.dart';
import '../../features/news/news_list_screen.dart';
import '../../features/onboarding/consent_screen.dart';
import '../../features/onboarding/language_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/weather/weather_screen.dart';
import '../../shell/vendor_shell.dart';
import '../providers/session_provider.dart';
import '../providers/settings_provider.dart';

/// Route paths in one place, so the redirect guard, the shells and any future
/// push-notification deep link cannot disagree about a URL.
abstract final class Routes {
  const Routes._();

  static const splash = '/';
  static const language = '/onboarding/language';
  static const consent = '/onboarding/consent';
  static const login = '/login';
  static const register = '/register';
  static const reset = '/reset';
  static const pending = '/pending-approval';

  static const home = '/home';
  static const assistant = '/assistant';
  static const advisory = '/advisory';
  static const cropAdvice = '/crop-advice';
  static const calendar = '/calendar';
  static const capture = '/diagnosis/capture';
  static const result = '/diagnosis/result';
  static const history = '/history';
  static const market = '/market';
  static const orders = '/orders';
  static const news = '/news';
  static const weather = '/weather';
  static const profile = '/profile';

  static const vendorHome = '/vendor';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Re-runs the route guard whenever the session or the first-run gates change.
class _RouterRefresh extends ChangeNotifier {
  _RouterRefresh(Ref ref) {
    ref.listen(sessionProvider, (_, _) => notifyListeners());
    ref.listen(settingsProvider, (_, _) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // The redirect guard below reads providers, but GoRouter only re-runs it when
  // something it listens to changes. Without this, a successful login left the
  // user sitting on the login form forever: the session had changed and the
  // guard would have allowed the shell, but nothing asked it to look again.
  final refresh = _RouterRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final settings = ref.read(settingsProvider);
      final session = ref.read(sessionProvider);
      final user = session.value;
      final path = state.matchedLocation;

      final onOnboarding = path == Routes.splash ||
          path == Routes.language ||
          path == Routes.consent;
      final onAuth = path == Routes.login ||
          path == Routes.register ||
          path == Routes.reset;

      // First run: language, then consent, before any credentials are asked for.
      if (!settings.languageChosen) {
        return path == Routes.language ? null : Routes.language;
      }
      if (!settings.consentGiven) {
        return path == Routes.consent ? null : Routes.consent;
      }

      // Still restoring the session from secure storage: hold on the splash
      // rather than flashing the login form at a signed-in user.
      if (session.isLoading && onOnboarding) return null;

      if (user == null) {
        // Signed out: auth screens are the only reachable places.
        if (path == Routes.pending) return Routes.login;
        return onAuth ? null : Routes.login;
      }

      // Vendor and expert start life unapproved (decision A7) and must not reach
      // their shell until an admin says so.
      if (user.needsApproval) {
        return path == Routes.pending ? null : Routes.pending;
      }

      final home = _homeFor(user.role);
      if (onAuth || onOnboarding || path == Routes.pending) return home;

      // Cross-role guard: a farmer cannot open /vendor and vice versa. The
      // server enforces this too; this stops the wasted round trip.
      if (_isOtherRolePath(path, user.role)) return home;

      return null;
    },
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (_, _) => const _SplashScreen(),
      ),
      GoRoute(
        path: Routes.language,
        builder: (_, _) => const LanguageScreen(),
      ),
      GoRoute(
        path: Routes.consent,
        builder: (_, _) => const ConsentScreen(),
      ),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.register, builder: (_, _) => const RegisterScreen()),
      GoRoute(path: Routes.reset, builder: (_, _) => const ResetPasswordScreen()),
      GoRoute(
        path: Routes.pending,
        builder: (_, _) => const PendingApprovalScreen(),
      ),

      // Farmer
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(path: Routes.capture, builder: (_, _) => const CaptureScreen()),
      GoRoute(
        path: Routes.result,
        builder: (_, state) =>
            ResultScreen(diagnosisId: state.uri.queryParameters['id']),
      ),
      GoRoute(path: Routes.history, builder: (_, _) => const HistoryScreen()),
      GoRoute(path: Routes.market, builder: (_, _) => const MarketScreen()),
      GoRoute(
        path: '${Routes.market}/:id',
        builder: (_, state) =>
            ProductDetailScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(path: Routes.orders, builder: (_, _) => const OrdersScreen()),
      GoRoute(path: Routes.news, builder: (_, _) => const NewsListScreen()),
      GoRoute(
        path: '${Routes.news}/:id',
        builder: (_, state) =>
            NewsDetailScreen(newsId: state.pathParameters['id']!),
      ),
      GoRoute(path: Routes.weather, builder: (_, _) => const WeatherScreen()),
      GoRoute(
        path: Routes.assistant,
        builder: (_, _) => const AssistantScreen(),
      ),
      GoRoute(
        path: Routes.advisory,
        builder: (_, _) => const AdvisoryScreen(),
      ),
      GoRoute(
        path: '${Routes.advisory}/:id',
        builder: (_, state) =>
            ArticleScreen(articleId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: Routes.cropAdvice,
        builder: (_, _) => const CropAdviceScreen(),
      ),
      GoRoute(
        path: '${Routes.calendar}/:crop',
        builder: (_, state) =>
            CalendarScreen(crop: state.pathParameters['crop']!),
      ),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),

      // Vendor / expert / admin share one shell for now; each role's own section
      // is a tab inside it.
      GoRoute(
        path: Routes.vendorHome,
        builder: (_, _) => const VendorShell(),
      ),
    ],
  );
});

String _homeFor(Role role) => switch (role) {
      Role.farmer => Routes.home,
      Role.vendor => Routes.vendorHome,
      Role.expert => Routes.vendorHome,
      Role.admin => Routes.vendorHome,
    };

bool _isOtherRolePath(String path, Role role) {
  final isVendorArea = path.startsWith(Routes.vendorHome);
  if (role == Role.farmer) return isVendorArea;
  return !isVendorArea;
}

/// Shown only while the session is restored. Keeps the brand mark on screen so a
/// cold start does not flash a bare white page.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_rounded, size: 96, color: scheme.secondary),
            const SizedBox(height: 24),
            Text(
              'AgriSense',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: scheme.onPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
