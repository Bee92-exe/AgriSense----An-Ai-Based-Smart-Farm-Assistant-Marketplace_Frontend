import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/enums.dart';
import '../../data/models/ops.dart';
import '../../data/providers.dart';

/// Vendor approvals (FR-22). Filtered by the wire status, `null` for all.
final adminVendorsProvider =
    FutureProvider.family<List<AdminVendor>, String?>((ref, status) async {
  return ref.watch(adminRepositoryProvider).vendors(status: status);
});

/// The account list, filtered server-side by the same three controls the screen
/// shows (FR-50).
typedef AdminUserQuery = ({String query, Role? role, AccountStatus? status});

final adminUsersProvider =
    FutureProvider.family<List<PlatformUser>, AdminUserQuery>(
  (ref, query) async => ref.watch(adminRepositoryProvider).users(
        query: query.query,
        role: query.role,
        status: query.status,
      ),
);

final adminSourcesProvider = FutureProvider<List<ManagedNewsSource>>(
  (ref) async => ref.watch(adminRepositoryProvider).sources(),
);

final adminScheduleProvider = FutureProvider<CollectionSchedule>(
  (ref) async => ref.watch(adminRepositoryProvider).schedule(),
);

final adminLogsProvider =
    FutureProvider.family<List<OpsLogEntry>, OpsLogType?>((ref, type) async {
  return ref.watch(adminRepositoryProvider).logs(type: type);
});
