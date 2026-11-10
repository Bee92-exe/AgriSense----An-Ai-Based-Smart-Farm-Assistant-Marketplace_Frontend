import 'package:flutter/foundation.dart' show kProfileMode, kReleaseMode;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/settings_provider.dart';
import 'local/diagnosis_queue.dart';
import 'local/pending_diagnosis_store.dart';
import 'mock/mock_article_repository.dart';
import 'mock/mock_ops_repositories.dart';
import 'mock/mock_repositories.dart';
import 'remote/api_client.dart';
import 'remote/remote_admin_repository.dart';
import 'remote/remote_article_repository.dart';
import 'remote/remote_auth_repository.dart';
import 'remote/remote_crop_repository.dart';
import 'remote/remote_diagnosis_repository.dart';
import 'remote/remote_expert_repository.dart';
import 'remote/remote_market_repository.dart';
import 'remote/remote_news_repository.dart';
import 'remote/remote_vendor_repository.dart';
import 'remote/remote_weather_repository.dart';
import 'remote/remote_voice_repository.dart';
import 'remote/token_store.dart';
import 'repositories/admin_repository.dart';
import 'repositories/article_repository.dart';
import 'repositories/auth_repository.dart';
import 'repositories/crop_repository.dart';
import 'repositories/diagnosis_repository.dart';
import 'repositories/expert_repository.dart';
import 'repositories/expert_review_repository.dart';
import 'repositories/market_repository.dart';
import 'repositories/news_repository.dart';
import 'repositories/vendor_repository.dart';
import 'repositories/voice_repository.dart';
import 'repositories/weather_repository.dart';

/// Shared so a failure rate raised in the debug menu applies to every remaining
/// mock at once instead of one repository at a time.
final mockConfigProvider = Provider<MockConfig>((ref) => MockConfig());

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final apiClientProvider = Provider<ApiClient>(
  (ref) => ApiClient(tokens: ref.watch(tokenStoreProvider)),
);

/// Mock repositories exist for the widget tests only.
///
/// A real build must never fall through to them. An earlier version returned
/// `true` when `WidgetsBinding` was not yet initialised, which meant that reading
/// any provider before `runApp` silently turned the whole app into demo data.
/// Release and profile builds are always remote; the test binding is the only
/// automatic signal.
final useMockRepositoriesProvider = Provider<bool>((ref) {
  if (kReleaseMode || kProfileMode) return false;
  if (const bool.fromEnvironment('USE_MOCKS')) return true;

  try {
    final binding = WidgetsBinding.instance;
    return binding.runtimeType.toString().contains('Test');
  } catch (_) {
    // No binding yet: a real launch, so use the real repositories.
    return false;
  }
});

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => RemoteAuthRepository(ref.watch(apiClientProvider)),
);

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  final useMock = ref.watch(useMockRepositoriesProvider);
  if (useMock) {
    return MockDiagnosisRepository(config: ref.watch(mockConfigProvider));
  }
  return RemoteDiagnosisRepository(
    ref.watch(apiClientProvider),
  );
});

final pendingDiagnosisStoreProvider = Provider<PendingDiagnosisStore>(
  (ref) => PendingDiagnosisStore(ref.watch(sharedPreferencesProvider)),
);

/// Photos captured without signal. Kept next to the repositories because it
/// drives `diagnosisRepositoryProvider` rather than living above it.
final diagnosisQueueProvider = Provider<DiagnosisQueue>(
  (ref) => DiagnosisQueue(
    repository: ref.watch(diagnosisRepositoryProvider),
    store: ref.watch(pendingDiagnosisStoreProvider),
  ),
);

final marketRepositoryProvider = Provider<MarketRepository>((ref) {
  if (ref.watch(useMockRepositoriesProvider)) {
    return MockMarketRepository(config: ref.watch(mockConfigProvider));
  }
  return RemoteMarketRepository(ref.watch(apiClientProvider));
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  if (ref.watch(useMockRepositoriesProvider)) {
    return MockNewsRepository(config: ref.watch(mockConfigProvider));
  }
  return RemoteNewsRepository(ref.watch(apiClientProvider));
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  if (ref.watch(useMockRepositoriesProvider)) {
    return MockWeatherRepository(config: ref.watch(mockConfigProvider));
  }
  return RemoteWeatherRepository(ref.watch(apiClientProvider));
});

final voiceRepositoryProvider = Provider<VoiceRepository>((ref) {
  final useMock = ref.watch(useMockRepositoriesProvider);
  if (useMock) {
    return MockVoiceRepository(config: ref.watch(mockConfigProvider));
  }
  return RemoteVoiceRepository(
    ref.watch(apiClientProvider),
  );
});

final cropRepositoryProvider = Provider<CropRepository>((ref) {
  if (ref.watch(useMockRepositoriesProvider)) {
    return MockCropRepository(config: ref.watch(mockConfigProvider));
  }
  return RemoteCropRepository(ref.watch(apiClientProvider));
});

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  if (ref.watch(useMockRepositoriesProvider)) {
    return MockVendorRepository(config: ref.watch(mockConfigProvider));
  }
  return RemoteVendorRepository(ref.watch(apiClientProvider));
});

final expertRepositoryProvider = Provider<ExpertRepository>((ref) {
  if (ref.watch(useMockRepositoriesProvider)) {
    return MockExpertRepository(config: ref.watch(mockConfigProvider));
  }
  return RemoteExpertRepository(ref.watch(apiClientProvider));
});

/// The review queue is the same desk, so it is the same instance. A second
/// object would let the tab badge and the queue list disagree.
final expertReviewRepositoryProvider = Provider<ExpertReviewRepository>(
  (ref) => ref.watch(expertRepositoryProvider) as ExpertReviewRepository,
);

/// The farmer's advisory feed, backed by the articles experts publish.
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  if (ref.watch(useMockRepositoriesProvider)) {
    return MockArticleRepository(
      expert: ref.watch(expertRepositoryProvider) as MockExpertRepository,
    );
  }
  return RemoteArticleRepository(ref.watch(apiClientProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => RemoteAdminRepository(ref.watch(apiClientProvider)),
);
