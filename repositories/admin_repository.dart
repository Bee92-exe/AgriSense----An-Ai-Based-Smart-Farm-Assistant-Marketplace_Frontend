import '../models/enums.dart';
import '../models/growth.dart';
import '../models/ops.dart';
import '../models/product.dart';

/// Platform administration (API_SPEC §9–§11): vendor approvals, user status,
/// news sources and the collection schedule, and the log view.
abstract interface class AdminRepository {
  Future<List<AdminVendor>> vendors({String? status});

  Future<AdminVendor> verifyVendor(String vendorId);

  Future<AdminVendor> rejectVendor(String vendorId, {required String reason});

  Future<AdminVendor> suspendVendor(String vendorId, {required String reason});

  Future<List<PlatformUser>> users({
    String query = '',
    Role? role,
    AccountStatus? status,
  });

  /// Also the path that approves a pending expert or farmer (`active`).
  Future<PlatformUser> setUserStatus(
    String userId,
    AccountStatus status, {
    String? reason,
  });

  Future<List<ManagedNewsSource>> sources();

  Future<ManagedNewsSource> saveSource(ManagedNewsSource source);

  Future<ManagedNewsSource> toggleSource(String sourceId, bool active);

  Future<void> removeSource(String sourceId);

  Future<CollectionSchedule> schedule();

  Future<CollectionSchedule> setSchedule({
    required int intervalHours,
    required bool enabled,
  });

  /// Runs the collector now and returns the log line it produced.
  Future<OpsLogEntry> runNow();

  Future<List<OpsLogEntry>> logs({OpsLogType? type});

  /// Platform health for the control-room home. One call so the figures on the
  /// home cannot disagree with the queues behind them.
  Future<AdminOverview> overview();

  /// Every vendor's listing, for catalogue monitoring. Admin can take a listing
  /// down but can never buy (the admin role has no order path at all).
  Future<List<AdminProduct>> products();

  Future<AdminProduct> setProductHidden(String productId, bool hidden);

  /// Orders across the platform, read-only for the admin.
  Future<List<Order>> allOrders();

  /// Published news and expert articles for moderation.
  Future<List<AdminContent>> content();

  /// Takes a published item off the farmer feed, or puts it back.
  Future<AdminContent> setContentHidden(String contentId, bool hidden);

  Future<AdminSettings> settings();

  Future<AdminSettings> saveSettings(AdminSettings settings);
}
