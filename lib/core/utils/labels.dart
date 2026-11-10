import '../../l10n/app_localizations.dart';
import '../../data/models/enums.dart';
import '../../data/models/ops.dart';

/// The categories a vendor can file a listing under (API_SPEC §6). Order matters:
/// the editor shows them in this order, seed first because that is what most
/// vendors in the pilot sell.
const List<String> kProductCategories = [
  'seed',
  'fertilizer',
  'pesticide',
  'fungicide',
  'equipment',
  'other',
];

/// The three families a news feed can be filed under (API_SPEC §9).
const List<String> kNewsSourceTypes = [
  'government',
  'research',
  'news_portal',
];

/// Bangla labels for domain enums.
///
/// Kept apart from the enums themselves so `data/models` stays free of Flutter
/// and l10n imports, and apart from the widgets so two components showing the
/// same status cannot drift into two different words for it.
extension SeverityLabel on Severity {
  String label(AppL10n l) => switch (this) {
        Severity.low => l.severityLow,
        Severity.medium => l.severityMedium,
        Severity.high => l.severityHigh,
        Severity.urgent => l.severityUrgent,
      };
}

extension ConfidenceLabel on ConfidenceLevel {
  String label(AppL10n l) => switch (this) {
        ConfidenceLevel.high => l.diagnosisConfidenceHigh,
        ConfidenceLevel.medium => l.diagnosisConfidenceMedium,
        ConfidenceLevel.low => l.diagnosisConfidenceLow,
      };
}

extension OrderStatusLabel on OrderStatus {
  String label(AppL10n l) => switch (this) {
        OrderStatus.pending => l.orderStatusPending,
        OrderStatus.confirmed => l.orderStatusConfirmed,
        OrderStatus.shipped => l.orderStatusShipped,
        OrderStatus.delivered => l.orderStatusDelivered,
        OrderStatus.rejected => l.orderStatusRejected,
        OrderStatus.cancelled => l.orderStatusCancelled,
      };
}

extension SyncStatusLabel on SyncStatus {
  String label(AppL10n l) => switch (this) {
        SyncStatus.queued => l.syncQueued,
        SyncStatus.uploading => l.syncUploading,
        SyncStatus.synced => l.syncSynced,
        SyncStatus.failed => l.syncFailed,
      };
}

extension NewsCategoryLabel on NewsCategory {
  String label(AppL10n l) => switch (this) {
        NewsCategory.disease => l.newsCategoryDisease,
        NewsCategory.pest => l.newsCategoryPest,
        NewsCategory.virus => l.newsCategoryVirus,
        NewsCategory.nutrientDeficiency => l.newsCategoryNutrient,
        NewsCategory.weather => l.newsCategoryWeather,
        NewsCategory.market => l.newsCategoryMarket,
        NewsCategory.advisory => l.newsCategoryAdvisory,
      };
}

extension RoleLabel on Role {
  String label(AppL10n l) => switch (this) {
        Role.farmer => l.roleFarmer,
        Role.vendor => l.roleVendor,
        Role.expert => l.roleExpert,
        // Admins are created by seed and never see a public label, but the
        // switch must be total.
        Role.admin => l.navUsers,
      };
}

extension CropLabel on CropType {
  String label(AppL10n l) => switch (this) {
        CropType.rice => l.diagnosisCropRice,
        CropType.potato => l.diagnosisCropPotato,
        CropType.tomato => l.diagnosisCropTomato,
      };
}

/// Labels for the staff vocabulary — the strings only a vendor, expert or admin
/// ever reads. Kept next to the enum labels so the same wire value cannot be
/// worded two ways in two screens.
extension OpsLabel on AppL10n {
  String productCategory(String wire) => switch (wire) {
        'seed' => categorySeed,
        'fertilizer' => categoryFertilizer,
        'pesticide' => categoryPesticide,
        'fungicide' => categoryFungicide,
        'equipment' => categoryEquipment,
        _ => categoryOther,
      };

  String draftStatus(DraftStatus status) => switch (status) {
        DraftStatus.needsWriting => draftNeedsWriting,
        DraftStatus.draft => draftInProgress,
        DraftStatus.published => draftPublished,
        DraftStatus.rejected => draftRejected,
      };

  String accountStatus(AccountStatus status) => switch (status) {
        AccountStatus.active => accountStatusActive,
        AccountStatus.pending => accountStatusPending,
        AccountStatus.suspended => accountStatusSuspended,
        AccountStatus.removed => accountStatusRemoved,
      };

  /// The four vendor approval states (`pending | verified | rejected |
  /// suspended`), shared by the admin list and the verification gate.
  String vendorVerification(String status) => switch (status) {
        'verified' => vendorVerified,
        'rejected' => vendorRejected,
        'suspended' => vendorSuspended,
        _ => vendorPendingReview,
      };

  String opsLogType(OpsLogType type) => switch (type) {
        OpsLogType.system => logTypeSystem,
        OpsLogType.collection => logTypeCollection,
        OpsLogType.voice => logTypeVoice,
        OpsLogType.aiFallback => logTypeAiFallback,
        OpsLogType.audit => logTypeAudit,
      };

  String newsSourceType(String wire) => switch (wire) {
        'research' => sourceTypeResearch,
        'news_portal' => sourceTypeNewsPortal,
        _ => sourceTypeGovernment,
      };
}
