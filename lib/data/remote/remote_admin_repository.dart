import '../models/enums.dart';
import '../models/growth.dart';
import '../models/ops.dart';
import '../models/product.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import 'api_client.dart';

class RemoteAdminRepository implements AdminRepository {
  RemoteAdminRepository(this._api);

  final ApiClient _api;

  @override
  Future<List<AdminVendor>> vendors({String? status}) async {
    final data = await _api.get(
      '/admin/vendors',
      query: status == null ? null : {'status': status},
    );
    return _mapList(data['vendors'], AdminVendor.fromJson);
  }

  @override
  Future<AdminVendor> verifyVendor(String vendorId) async {
    final data = await _api.post('/admin/vendors/$vendorId/verify');
    return AdminVendor.fromJson(data['vendor'] as Map<String, dynamic>);
  }

  @override
  Future<AdminVendor> rejectVendor(
    String vendorId, {
    required String reason,
  }) async {
    final data = await _api.post(
      '/admin/vendors/$vendorId/reject',
      body: {'reason': reason},
    );
    return AdminVendor.fromJson(data['vendor'] as Map<String, dynamic>);
  }

  @override
  Future<AdminVendor> suspendVendor(
    String vendorId, {
    required String reason,
  }) async {
    final data = await _api.post(
      '/admin/vendors/$vendorId/suspend',
      body: {'reason': reason},
    );
    return AdminVendor.fromJson(data['vendor'] as Map<String, dynamic>);
  }

  @override
  Future<List<PlatformUser>> users({
    String query = '',
    Role? role,
    AccountStatus? status,
  }) async {
    final params = <String, String>{};
    if (query.trim().isNotEmpty) params['query'] = query.trim();
    if (role != null) params['role'] = role.wire;
    if (status != null) params['status'] = status.wire;

    final data = await _api.get(
      '/admin/users',
      query: params.isEmpty ? null : params,
    );
    return _mapList(data['users'], PlatformUser.fromJson);
  }

  @override
  Future<PlatformUser> setUserStatus(
    String userId,
    AccountStatus status, {
    String? reason,
  }) async {
    final data = await _api.patch(
      '/admin/users/$userId/status',
      body: {
        'status': status.wire,
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    return PlatformUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<String> resetUserPassword(String userId, {String? reason}) async {
    final data = await _api.post(
      '/admin/users/$userId/reset-password',
      body: {
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      },
    );
    final temporary = data['temporary_password'] as String?;
    if (temporary == null || temporary.isEmpty) {
      throw const ApiException(
        code: 'server_error',
        messageKey: 'stateErrorBody',
      );
    }
    return temporary;
  }

  @override
  Future<List<OpsLogEntry>> logs({OpsLogType? type}) async {
    final data = await _api.get(
      '/admin/logs',
      query: type == null ? null : {'type': type.wire},
    );
    return _mapList(data['logs'], OpsLogEntry.fromJson);
  }

  @override
  Future<AdminOverview> overview() async {
    final data = await _api.get('/admin/overview');
    final json = data['overview'] as Map<String, dynamic>;

    final week = ((json['week'] as List<dynamic>?) ?? const [])
        .map((item) {
          final map = item as Map<String, dynamic>;
          return TrendPoint(
            day: DateTime.tryParse(map['day'] as String? ?? '') ??
                DateTime.now(),
            value: (map['value'] as num?)?.toDouble() ?? 0,
          );
        })
        .toList();

    return AdminOverview(
      gmv30: (json['gmv30'] as num?)?.toInt() ?? 0,
      commission30: (json['commission30'] as num?)?.toInt() ?? 0,
      activeUsers: (json['activeUsers'] as num?)?.toInt() ?? 0,
      newUsers7: (json['newUsers7'] as num?)?.toInt() ?? 0,
      orders30: (json['orders30'] as num?)?.toInt() ?? 0,
      pendingApprovals: (json['pendingApprovals'] as num?)?.toInt() ?? 0,
      openIssues: (json['openIssues'] as num?)?.toInt() ?? 0,
      vendors: (json['vendors'] as num?)?.toInt() ?? 0,
      week: week,
    );
  }

  @override
  Future<List<AdminProduct>> products() async {
    final data = await _api.get('/admin/products');
    return _mapList(data['products'], (json) {
      return AdminProduct(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        shopName: json['shop_name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        price: (json['price'] as num?)?.toInt() ?? 0,
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        hidden: json['hidden'] as bool? ?? false,
      );
    });
  }

  // The remaining admin surfaces are Phase 2/3 work. Reading an empty list
  // where the database has no such table is honest; mutations fail loudly so
  // the UI cannot report that it saved something it did not.
  @override
  Future<List<ManagedNewsSource>> sources() async => const [];

  @override
  Future<List<AdminContent>> content() async => const [];

  @override
  Future<List<Order>> allOrders() async => const [];

  @override
  Future<CollectionSchedule> schedule() async => _notImplemented();

  @override
  Future<AdminSettings> settings() async => _notImplemented();

  @override
  Future<AdminSettings> saveSettings(AdminSettings settings) async =>
      _notImplemented();

  @override
  Future<ManagedNewsSource> saveSource(ManagedNewsSource source) async =>
      _notImplemented();

  @override
  Future<ManagedNewsSource> toggleSource(String sourceId, bool active) async =>
      _notImplemented();

  @override
  Future<void> removeSource(String sourceId) async => _notImplemented();

  @override
  Future<CollectionSchedule> setSchedule({
    required int intervalHours,
    required bool enabled,
  }) async =>
      _notImplemented();

  @override
  Future<OpsLogEntry> runNow() async => _notImplemented();

  @override
  Future<AdminProduct> setProductHidden(String productId, bool hidden) async =>
      _notImplemented();

  @override
  Future<AdminContent> setContentHidden(String contentId, bool hidden) async =>
      _notImplemented();

  Never _notImplemented() {
    throw const ApiException(
      code: 'not_implemented',
      messageKey: 'stateErrorBody',
      statusCode: 501,
    );
  }

  List<T> _mapList<T>(
    Object? value,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return ((value as List<dynamic>?) ?? const [])
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
