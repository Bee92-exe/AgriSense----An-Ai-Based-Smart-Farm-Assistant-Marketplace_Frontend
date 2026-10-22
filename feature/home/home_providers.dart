import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/session_provider.dart';
import '../../data/models/diagnosis.dart';
import '../../data/models/news_item.dart';
import '../../data/models/weather.dart';
import '../../data/providers.dart';

/// Weather for the signed-in user's district.
///
/// Watches the session so switching district in the profile invalidates it
/// automatically instead of leaving the previous district's forecast on screen.
final homeWeatherProvider = FutureProvider<WeatherReport>((ref) async {
  final user = ref.watch(currentUserProvider);
  return ref
      .watch(weatherRepositoryProvider)
      .report(district: user?.district);
});

/// The newest Krishi Barta items, for the home list and the unread badge.
final homeNewsProvider = FutureProvider<List<NewsItem>>((ref) async {
  return ref.watch(newsRepositoryProvider).list();
});

/// The farmer's recent diagnosis history, newest first.
final diagnosisHistoryProvider = FutureProvider<List<Diagnosis>>((ref) async {
  return ref.watch(diagnosisRepositoryProvider).history();
});

/// A single diagnosis by id, for the result screen after a fresh upload.
final diagnosisByIdProvider =
    FutureProvider.family<Diagnosis, String>((ref, id) async {
  return ref.watch(diagnosisRepositoryProvider).detail(id);
});

/// The most recent diagnosis, used by the "order this pesticide" entry point and
/// by the low-confidence nudge on Home.
final latestDiagnosisProvider = FutureProvider<Diagnosis?>((ref) async {
  final history = await ref.watch(diagnosisRepositoryProvider).history();
  return history.isEmpty ? null : history.first;
});

/// Unread count for the Krishi Barta badge.
final unreadNewsCountProvider = FutureProvider<int>((ref) async {
  final items = await ref.watch(homeNewsProvider.future);
  return items.where((n) => !n.isRead).length;
});
