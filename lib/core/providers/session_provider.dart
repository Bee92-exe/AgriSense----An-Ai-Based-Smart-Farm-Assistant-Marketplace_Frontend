import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user.dart';
import '../../data/providers.dart';
import '../../data/repositories/auth_repository.dart';

/// The signed-in user, or null.
///
/// Riverpod's `AsyncValue` is used rather than a hand-rolled loading flag so
/// every screen gets loading/error/data handling from the same shape, and a
/// failed login is an `AsyncError` the form can read directly instead of a
/// separate error field that can drift out of sync.
class SessionNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() =>
      ref.read(authRepositoryProvider).restoreSession();

  Future<void> login({required String mobile, required String password}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(
            mobile: mobile,
            password: password,
          ),
    );
  }

  Future<AppUser?> register(RegisterRequest request) async {
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(request),
    );
    state = result;
    return result.value;
  }

  Future<void> requestPasswordReset(String mobile) async {
    await ref.read(authRepositoryProvider).requestPasswordReset(mobile);
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await ref.read(authRepositoryProvider).resetPassword(
            token: token,
            newPassword: newPassword,
          );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }

  /// Applies a profile edit the server has already accepted.
  void replaceUser(AppUser user) => state = AsyncValue.data(user);
}

final sessionProvider =
    AsyncNotifierProvider<SessionNotifier, AppUser?>(SessionNotifier.new);

/// Convenience for widgets that only care about "is anyone signed in".
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(sessionProvider).value,
);
