import 'package:flutter/foundation.dart';

import 'diagnosis.dart';
import 'enums.dart';
import 'product.dart';

/// Where a Krishi Barta draft is in the expert review pipeline (API_SPEC §9).
enum DraftStatus {
  needsWriting('needs_expert_writing'),
  draft('draft'),
  published('published'),
  rejected('rejected');

  const DraftStatus(this.wire);

  final String wire;

  static DraftStatus fromWire(String? value) => DraftStatus.values.firstWhere(
        (s) => s.wire == value,
        orElse: () => DraftStatus.needsWriting,
      );
}

/// The log families the admin console can filter on (API_SPEC §10).
enum OpsLogType {
  system('system'),
  collection('collection'),
  voice('voice'),
  aiFallback('ai_fallback'),
  audit('audit');

  const OpsLogType(this.wire);

  final String wire;

  static OpsLogType fromWire(String? value) => OpsLogType.values.firstWhere(
        (t) => t.wire == value,
        orElse: () => OpsLogType.system,
      );
}

/// One order as the vendor sees it: the order itself plus the buyer contact the
/// farmer handed over by placing it. Only ever built for the vendor's own
/// orders (doc 04), never for a browsing vendor.
@immutable
class VendorOrder {
  const VendorOrder({
    required this.order,
    required this.buyerName,
    required this.buyerMobile,
    required this.buyerDistrict,
    this.note,
  });

  final Order order;
  final String buyerName;
  final String buyerMobile;
  final String buyerDistrict;
  final String? note;

  /// The transitions the vendor may perform next (API_SPEC §7). Anything not in
  /// this list is not offered, so an invalid transition cannot be attempted
  /// from the UI at all.
  List<OrderStatus> get nextActions => switch (order.status) {
        OrderStatus.pending => [OrderStatus.confirmed, OrderStatus.rejected],
        OrderStatus.confirmed => [OrderStatus.shipped],
        OrderStatus.shipped => [OrderStatus.delivered],
        _ => const [],
      };
}

/// One farmer rating, read-only for the vendor.
@immutable
class VendorRating {
  const VendorRating({
    required this.rating,
    required this.comment,
    required this.farmerName,
    required this.createdAt,
  });

  final int rating;
  final String comment;
  final String farmerName;
  final DateTime createdAt;
}

/// Everything the vendor dashboard needs, fetched together so the stats, the
/// low-stock list and the order count cannot disagree.
@immutable
class VendorDesk {
  const VendorDesk({
    required this.products,
    required this.orders,
    required this.ratings,
    required this.ratingCount,
    required this.averageRating,
  });

  final List<Product> products;
  final List<VendorOrder> orders;
  final List<VendorRating> ratings;
  final int ratingCount;
  final double averageRating;

  List<Product> get lowStock => products
      .where((p) => p.stock > 0 && p.stock <= 10)
      .toList(growable: false);

  List<Product> get outOfStock =>
      products.where((p) => p.stock == 0).toList(growable: false);

  int get pendingOrders =>
      orders.where((o) => o.order.status == OrderStatus.pending).length;

  int get todayOrders {
    final now = DateTime.now();
    return orders
        .where(
          (o) =>
              o.order.createdAt.year == now.year &&
              o.order.createdAt.month == now.month &&
              o.order.createdAt.day == now.day,
        )
        .length;
  }

  int get revenueToday {
    final now = DateTime.now();
    return orders
        .where(
          (o) =>
              o.order.createdAt.year == now.year &&
              o.order.createdAt.month == now.month &&
              o.order.createdAt.day == now.day &&
              o.order.status != OrderStatus.rejected &&
              o.order.status != OrderStatus.cancelled,
        )
        .fold(0, (sum, o) => sum + o.order.totalAmount);
  }
}

/// The fields a vendor may set on a product (API_SPEC §6). `id` is null for a
/// new listing; the server assigns it.
@immutable
class VendorProductDraft {
  const VendorProductDraft({
    this.id,
    required this.name,
    this.nameBn,
    required this.category,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
  });

  final String? id;
  final String name;
  final String? nameBn;
  final String category;
  final int price;
  final int stock;
  final String? description;

  /// A link to the listing photo. Uploading the bytes themselves waits for the
  /// storage endpoint; the field is already here so the editor does not have to
  /// change shape when that lands.
  final String? imageUrl;
}

/// A low-confidence diagnosis waiting for an expert (API_SPEC §3).
@immutable
class ReviewCase {
  const ReviewCase({
    required this.id,
    required this.diagnosisId,
    required this.farmerName,
    required this.farmerDistrict,
    required this.crop,
    required this.confidence,
    required this.createdAt,
    required this.resolved,
    this.top3 = const [],
    this.resolutionDiseaseId,
    this.resolutionDiseaseName,
    this.note,
    this.needsRetake = false,
  });

  final String id;

  /// Null for a case that arrived from the server without a linked diagnosis
  /// (the mock's review queue is its own list).
  final String? diagnosisId;

  final String farmerName;
  final String farmerDistrict;
  final CropType? crop;
  final double confidence;
  final DateTime createdAt;
  final bool resolved;
  final List<(Disease, double)> top3;
  final String? resolutionDiseaseId;
  final String? resolutionDiseaseName;
  final String? note;

  /// The expert asked for a clearer photo instead of naming a disease.
  final bool needsRetake;

  ConfidenceLevel get level => ConfidenceLevel.fromScore(confidence);

  factory ReviewCase.fromJson(Map<String, dynamic> json) => ReviewCase(
        id: json['id'] as String,
        diagnosisId: json['diagnosis_id'] as String?,
        farmerName: json['farmer_name'] as String? ?? '',
        farmerDistrict: json['farmer_district'] as String? ?? '',
        crop: CropType.fromWire(json['crop'] as String?),
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        resolved: json['status'] == 'resolved',
        top3: ((json['ai_top3'] as List<dynamic>?) ?? const [])
            .map((e) => e as Map<String, dynamic>)
            .map(
              (m) => (
                Disease(
                  id: m['disease_id'] as String? ?? '',
                  nameBn: m['name_bn'] as String? ?? '',
                  nameEn: m['name_en'] as String? ?? '',
                ),
                (m['confidence'] as num?)?.toDouble() ?? 0,
              ),
            )
            .toList(),
        resolutionDiseaseId: json['resolution_disease_id'] as String?,
        resolutionDiseaseName: json['resolution_disease_name'] as String?,
        note: json['note'] as String?,
        needsRetake: json['needs_retake'] as bool? ?? false,
      );
}

/// One Krishi Barta item as the expert/editor sees it — including the source
/// text and AI tags a farmer never sees.
@immutable
class NewsDraft {
  const NewsDraft({
    required this.id,
    required this.status,
    required this.titleBn,
    required this.summaryBn,
    required this.category,
    required this.crop,
    required this.severity,
    required this.affectedDistricts,
    required this.sourceName,
    required this.sourceUrl,
    required this.updatedAt,
    this.symptomsBn,
    this.advisedActionBn,
    this.sourceExcerpt,
    this.aiTags = const [],
    this.aiConfidence,
    this.urgent = false,
    this.rejectReason,
    this.publishedAt,
  });

  final String id;
  final DraftStatus status;
  final String titleBn;
  final String summaryBn;
  final String? symptomsBn;
  final String? advisedActionBn;
  final NewsCategory category;
  final CropType crop;
  final Severity severity;
  final List<String> affectedDistricts;
  final String sourceName;
  final String sourceUrl;
  final String? sourceExcerpt;
  final List<String> aiTags;
  final double? aiConfidence;
  final bool urgent;
  final String? rejectReason;
  final DateTime? publishedAt;
  final DateTime updatedAt;

  NewsDraft copyWith({
    DraftStatus? status,
    String? titleBn,
    String? summaryBn,
    String? symptomsBn,
    String? advisedActionBn,
    NewsCategory? category,
    Severity? severity,
    String? sourceName,
    String? sourceUrl,
    String? sourceExcerpt,
    List<String>? aiTags,
    double? aiConfidence,
    bool? urgent,
    String? rejectReason,
    DateTime? publishedAt,
  }) =>
      NewsDraft(
        id: id,
        status: status ?? this.status,
        titleBn: titleBn ?? this.titleBn,
        summaryBn: summaryBn ?? this.summaryBn,
        symptomsBn: symptomsBn ?? this.symptomsBn,
        advisedActionBn: advisedActionBn ?? this.advisedActionBn,
        category: category ?? this.category,
        crop: crop,
        severity: severity ?? this.severity,
        affectedDistricts: affectedDistricts,
        sourceName: sourceName ?? this.sourceName,
        sourceUrl: sourceUrl ?? this.sourceUrl,
        sourceExcerpt: sourceExcerpt ?? this.sourceExcerpt,
        aiTags: aiTags ?? this.aiTags,
        aiConfidence: aiConfidence ?? this.aiConfidence,
        urgent: urgent ?? this.urgent,
        rejectReason: rejectReason ?? this.rejectReason,
        publishedAt: publishedAt ?? this.publishedAt,
        updatedAt: DateTime.now(),
      );

  factory NewsDraft.fromJson(Map<String, dynamic> json) => NewsDraft(
        id: json['id'] as String,
        status: DraftStatus.fromWire(json['status'] as String?),
        titleBn: json['title_bn'] as String? ?? '',
        summaryBn: json['summary_bn'] as String? ?? '',
        symptomsBn: json['symptoms_bn'] as String?,
        advisedActionBn: json['advised_action_bn'] as String?,
        category: NewsCategory.fromWire(json['category'] as String?),
        crop: CropType.fromWire(json['crop'] as String?) ?? CropType.rice,
        severity: Severity.fromWire(json['severity'] as String?),
        affectedDistricts:
            ((json['affected_districts'] as List<dynamic>?) ?? const [])
                .map((e) => e.toString())
                .toList(),
        sourceName: (json['source_name'] as String?) ??
            ((json['source'] as Map<String, dynamic>?)?['name'] as String? ??
                ''),
        sourceUrl: (json['source_url'] as String?) ??
            ((json['source'] as Map<String, dynamic>?)?['url'] as String? ?? ''),
        sourceExcerpt: json['source_excerpt'] as String?,
        aiTags: ((json['ai_tags'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        aiConfidence: (json['ai_confidence'] as num?)?.toDouble(),
        urgent: json['is_urgent'] as bool? ?? false,
        rejectReason: json['reject_reason'] as String?,
        publishedAt: DateTime.tryParse(json['published_at'] as String? ?? ''),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
      );
}

/// One knowledge-base entry (API_SPEC §11). Saving bumps [version] and queues
/// a reindex, which the screen states rather than hiding.
@immutable
class KnowledgeEntry {
  const KnowledgeEntry({
    required this.id,
    required this.diseaseId,
    required this.diseaseName,
    required this.crop,
    required this.protocolBn,
    required this.source,
    required this.safetyNoteBn,
    required this.version,
    required this.updatedAt,
    this.reindexQueued = false,
  });

  final String id;
  final String diseaseId;
  final String diseaseName;
  final CropType? crop;
  final String protocolBn;
  final String source;
  final String safetyNoteBn;
  final int version;
  final DateTime updatedAt;
  final bool reindexQueued;

  factory KnowledgeEntry.fromJson(Map<String, dynamic> json) => KnowledgeEntry(
        id: json['id'] as String,
        diseaseId: json['disease_id'] as String? ?? '',
        diseaseName: json['disease_name'] as String? ?? '',
        crop: CropType.fromWire(json['crop'] as String?),
        protocolBn: json['protocol_bn'] as String? ?? '',
        source: json['source'] as String? ?? '',
        safetyNoteBn: json['safety_note_bn'] as String? ?? '',
        version: (json['version'] as num?)?.toInt() ?? 1,
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.now(),
        reindexQueued: json['reindex_queued'] as bool? ?? false,
      );
}

/// A vendor account in the admin approval list (API_SPEC §10).
@immutable
class AdminVendor {
  const AdminVendor({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.ownerMobile,
    required this.district,
    required this.licenseNo,
    required this.status,
    required this.submittedAt,
    this.reason,
  });

  final String id;
  final String shopName;
  final String ownerName;
  final String ownerMobile;
  final String district;
  final String licenseNo;

  /// `pending | verified | rejected | suspended`
  final String status;
  final DateTime submittedAt;
  final String? reason;

  bool get isPending => status == 'pending';
  bool get isVerified => status == 'verified';

  AdminVendor copyWith({String? status, String? reason}) => AdminVendor(
        id: id,
        shopName: shopName,
        ownerName: ownerName,
        ownerMobile: ownerMobile,
        district: district,
        licenseNo: licenseNo,
        status: status ?? this.status,
        submittedAt: submittedAt,
        reason: reason ?? this.reason,
      );

  factory AdminVendor.fromJson(Map<String, dynamic> json) => AdminVendor(
        id: json['id'] as String,
        shopName: json['shop_name'] as String? ?? '',
        ownerName: json['owner_name'] as String? ?? '',
        ownerMobile: json['owner_mobile'] as String? ?? '',
        district: json['district'] as String? ?? '',
        licenseNo: json['license_no'] as String? ?? '',
        status: json['status'] as String? ?? 'pending',
        submittedAt: DateTime.tryParse(json['submitted_at'] as String? ?? '') ??
            DateTime.now(),
        reason: json['reason'] as String?,
      );
}

/// Any platform account in the admin user list.
@immutable
class PlatformUser {
  const PlatformUser({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
    required this.status,
    required this.district,
    required this.joinedAt,
    this.reason,
  });

  final String id;
  final String name;
  final String mobile;
  final Role role;
  final AccountStatus status;
  final String district;
  final DateTime joinedAt;
  final String? reason;

  factory PlatformUser.fromJson(Map<String, dynamic> json) => PlatformUser(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        mobile: json['mobile'] as String? ?? '',
        role: Role.fromWire(json['role'] as String?),
        status: AccountStatus.fromWire(json['status'] as String?),
        district: json['district'] as String? ?? '',
        joinedAt: DateTime.tryParse(json['joined_at'] as String? ?? '') ??
            DateTime.now(),
        reason: json['reason'] as String?,
      );
}

/// A news source the collector polls, with its last run result.
@immutable
class ManagedNewsSource {
  const ManagedNewsSource({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.active,
    this.lastRunAt,
    this.lastRunOk,
    this.lastError,
    this.itemsLastRun = 0,
  });

  final String id;
  final String name;
  final String url;

  /// `government | research | news_portal`
  final String type;
  final bool active;
  final DateTime? lastRunAt;
  final bool? lastRunOk;
  final String? lastError;
  final int itemsLastRun;

  ManagedNewsSource copyWith({
    bool? active,
    DateTime? lastRunAt,
    bool? lastRunOk,
    String? lastError,
    int? itemsLastRun,
  }) =>
      ManagedNewsSource(
        id: id,
        name: name,
        url: url,
        type: type,
        active: active ?? this.active,
        lastRunAt: lastRunAt ?? this.lastRunAt,
        lastRunOk: lastRunOk ?? this.lastRunOk,
        lastError: lastError ?? this.lastError,
        itemsLastRun: itemsLastRun ?? this.itemsLastRun,
      );

  factory ManagedNewsSource.fromJson(Map<String, dynamic> json) =>
      ManagedNewsSource(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        url: json['url'] as String? ?? '',
        type: json['type'] as String? ?? 'government',
        active: json['active'] as bool? ?? true,
        lastRunAt: DateTime.tryParse(json['last_run_at'] as String? ?? ''),
        lastRunOk: json['last_run_ok'] as bool?,
        lastError: json['last_error'] as String?,
        itemsLastRun: (json['items_last_run'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'type': type,
        'active': active,
        'last_run_at': lastRunAt?.toIso8601String(),
        'last_run_ok': lastRunOk,
        'last_error': lastError,
        'items_last_run': itemsLastRun,
      };
}

/// Collection interval for the news collector (API_SPEC §9, 1–24 hours).
@immutable
class CollectionSchedule {
  const CollectionSchedule({
    required this.intervalHours,
    required this.enabled,
    required this.nextRunAt,
  });

  final int intervalHours;
  final bool enabled;
  final DateTime nextRunAt;
}

/// One line in the admin log view.
@immutable
class OpsLogEntry {
  const OpsLogEntry({
    required this.id,
    required this.type,
    required this.message,
    required this.at,
  });

  final String id;
  final OpsLogType type;
  final String message;
  final DateTime at;

  factory OpsLogEntry.fromJson(Map<String, dynamic> json) => OpsLogEntry(
        id: json['id'] as String,
        type: OpsLogType.fromWire(json['type'] as String?),
        message: json['message'] as String? ?? '',
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
      );
}
