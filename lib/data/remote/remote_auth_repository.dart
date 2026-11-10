import '../models/enums.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'api_client.dart';

class RemoteAuthRepository implements AuthRepository {
  RemoteAuthRepository(this._api);

  final ApiClient _api;

  @override
  Future<AppUser> login({
    required String mobile,
    required String password,
  }) async {
    final data = await _api.post(
      '/auth/login',
      auth: false,
      body: {'mobile': mobile, 'password': password},
    );
    return _acceptSession(data);
  }

  @override
  Future<AppUser> register(RegisterRequest request) async {
    final data = await _api.post(
      '/auth/register',
      auth: false,
      body: {
        'name': request.name,
        'mobile': request.mobile,
        'password': request.password,
        'role': request.role.wire,
        'district': request.district,
        if (request.shopName != null && request.shopName!.isNotEmpty)
          'shop_name': request.shopName,
        if (request.licenseNo != null && request.licenseNo!.isNotEmpty)
          'license_no': request.licenseNo,
        if (request.specialization != null &&
            request.specialization!.isNotEmpty)
          'specialization': request.specialization,
        if (request.certification != null &&
            request.certification!.isNotEmpty)
          'certification': request.certification,
      },
    );
    return _acceptSession(data);
  }

  @override
  Future<void> requestPasswordReset(String mobile) async {
    await _api.post(
      '/auth/password/forgot',
      auth: false,
      body: {'mobile': mobile},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _api.post(
      '/auth/password/reset',
      auth: false,
      body: {'token': token, 'newPassword': newPassword},
    );
  }

  @override
  Future<void> logout() async {
    final refresh = await _api.tokens.readRefresh();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _api.post(
          '/auth/logout',
          auth: false,
          body: {'refresh': refresh},
        );
      } catch (_) {
        // The local session is cleared even when the server is unreachable; a
        // dead refresh token is already useless.
      }
    }
    await _api.tokens.clear();
  }

  @override
  Future<AppUser?> restoreSession() async {
    final access = await _api.tokens.readAccess();
    if (access == null || access.isEmpty) return null;

    try {
      final data = await _api.get('/users/me');
      final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
      if (user.status == AccountStatus.suspended ||
          user.status == AccountStatus.removed) {
        await _api.tokens.clear();
        return null;
      }
      return user;
    } on ApiException catch (error) {
      if (error.statusCode == 401) {
        await _api.tokens.clear();
      }
      return null;
    }
  }

  Future<AppUser> _acceptSession(Map<String, dynamic> data) async {
    final access = data['access'] as String?;
    final refresh = data['refresh'] as String?;
    final userJson = data['user'];

    if (access == null || refresh == null || userJson is! Map<String, dynamic>) {
      throw const ApiException(
        code: 'server_error',
        messageKey: 'stateErrorBody',
      );
    }

    await _api.tokens.save(access: access, refresh: refresh);
    return AppUser.fromJson(userJson);
  }
}
