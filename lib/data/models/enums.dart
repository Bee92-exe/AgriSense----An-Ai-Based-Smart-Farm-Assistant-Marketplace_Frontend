import 'package:flutter/material.dart';

/// Roles in the one app. Vendor, Expert and Admin are the same binary as
/// Farmer — only the shell and the permissions differ (decision D2).
enum Role {
  farmer('farmer'),
  vendor('vendor'),
  expert('expert'),
  admin('admin');

  const Role(this.wire);

  final String wire;

  static Role fromWire(String? value) => Role.values.firstWhere(
        (r) => r.wire == value,
        orElse: () => Role.farmer,
      );
}

enum AccountStatus {
  active('active'),
  pending('pending'),
  suspended('suspended'),
  removed('removed');

  const AccountStatus(this.wire);

  final String wire;

  static AccountStatus fromWire(String? value) => AccountStatus.values.firstWhere(
        (s) => s.wire == value,
        orElse: () => AccountStatus.active,
      );
}

enum CropType {
  rice('rice'),
  potato('potato'),
  tomato('tomato');

  const CropType(this.wire);

  final String wire;

  static CropType? fromWire(String? value) {
    if (value == null) return null;
    for (final c in CropType.values) {
      if (c.wire == value) return c;
    }
    return null;
  }
}

/// How much the AI trusts its own answer.
///
/// The 0.85 / 0.70 boundaries are a safety rule from the PRD and the design
/// system, not a styling choice: below 0.70 the app must never present a disease
/// as final, and between 0.70 and 0.85 it must show a caution note. Pinned by
/// `test/confidence_level_test.dart`.
enum ConfidenceLevel {
  high('high'),
  medium('medium'),
  low('low');

  const ConfidenceLevel(this.wire);

  final String wire;

  static const double highThreshold = 0.85;
  static const double lowThreshold = 0.70;

  static ConfidenceLevel fromScore(double score) {
    if (score >= highThreshold) return ConfidenceLevel.high;
    if (score >= lowThreshold) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  static ConfidenceLevel fromWire(String? value) => ConfidenceLevel.values
      .firstWhere((l) => l.wire == value, orElse: () => ConfidenceLevel.low);

  /// Only a high or medium score may be shown to a farmer as an answer.
  bool get isShowable => this != ConfidenceLevel.low;

  /// Medium must carry the "I am not fully sure" caution line.
  bool get needsCaution => this == ConfidenceLevel.medium;

  IconData get icon => switch (this) {
        ConfidenceLevel.high => Icons.verified_rounded,
        ConfidenceLevel.medium => Icons.help_rounded,
        ConfidenceLevel.low => Icons.report_rounded,
      };
}

enum Severity {
  low('low'),
  medium('medium'),
  high('high'),
  urgent('urgent');

  const Severity(this.wire);

  final String wire;

  static Severity fromWire(String? value) => Severity.values.firstWhere(
        (s) => s.wire == value,
        orElse: () => Severity.low,
      );

  /// Never colour alone: every chip carries this glyph and a Bangla label.
  IconData get icon => switch (this) {
        Severity.low => Icons.check_circle_rounded,
        Severity.medium => Icons.warning_amber_rounded,
        Severity.high => Icons.priority_high_rounded,
        Severity.urgent => Icons.emergency_rounded,
      };

  bool get needsPush => this == Severity.urgent || this == Severity.high;
}

enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  shipped('shipped'),
  delivered('delivered'),
  rejected('rejected'),
  cancelled('cancelled');

  const OrderStatus(this.wire);

  final String wire;

  static OrderStatus fromWire(String? value) => OrderStatus.values.firstWhere(
        (s) => s.wire == value,
        orElse: () => OrderStatus.pending,
      );

  /// The farmer-facing grouping: A4 says the farmer UI may fold Confirmed in
  /// under Pending, which is why the API sends `display_status` separately.
  OrderStatus get farmerVisible =>
      this == OrderStatus.confirmed ? OrderStatus.pending : this;

  bool get isTerminal =>
      this == OrderStatus.delivered ||
      this == OrderStatus.rejected ||
      this == OrderStatus.cancelled;
}

enum SyncStatus {
  queued('queued'),
  uploading('uploading'),
  synced('synced'),
  failed('failed');

  const SyncStatus(this.wire);

  final String wire;

  IconData get icon => switch (this) {
        SyncStatus.queued => Icons.schedule_rounded,
        SyncStatus.uploading => Icons.cloud_upload_rounded,
        SyncStatus.synced => Icons.cloud_done_rounded,
        SyncStatus.failed => Icons.cloud_off_rounded,
      };
}

enum NewsCategory {
  disease('disease'),
  pest('pest'),
  virus('virus'),
  nutrientDeficiency('nutrient_deficiency'),
  weather('weather'),
  market('market'),
  advisory('advisory');

  const NewsCategory(this.wire);

  final String wire;

  static NewsCategory fromWire(String? value) => NewsCategory.values.firstWhere(
        (c) => c.wire == value,
        orElse: () => NewsCategory.disease,
      );

  IconData get icon => switch (this) {
        NewsCategory.disease => Icons.coronavirus_rounded,
        NewsCategory.pest => Icons.bug_report_rounded,
        NewsCategory.virus => Icons.science_rounded,
        NewsCategory.nutrientDeficiency => Icons.eco_rounded,
        NewsCategory.weather => Icons.cloud_rounded,
        NewsCategory.market => Icons.storefront_rounded,
        NewsCategory.advisory => Icons.campaign_rounded,
      };
}

enum ReviewStatus {
  pending('pending'),
  resolved('resolved');

  const ReviewStatus(this.wire);

  final String wire;
}

/// Where a requested action came from. Recorded on orders so the pilot can
/// compare voice against touch journeys (FR-19 `placed_via`).
enum InputMode {
  touch('touch'),
  voice('voice');

  const InputMode(this.wire);

  final String wire;
}
