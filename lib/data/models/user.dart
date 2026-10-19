// widgets.dart (not foundation.dart) because it re-exports `characters`, which
// is what makes [AppUser.initials] safe on a Bangla conjunct.
import 'package:flutter/widgets.dart';

import 'enums.dart';

/// Vendor profile, present only when [AppUser.role] is [Role.vendor].
@immutable
class VendorProfile {
  const VendorProfile({
    required this.shopName,
    required this.verificationStatus,
    this.rating,
  });

  final String shopName;

  /// `pending | verified | rejected | suspended` (API_SPEC §1).
  final String verificationStatus;
  final double? rating;

  bool get isVerified => verificationStatus == 'verified';

  factory VendorProfile.fromJson(Map<String, dynamic> json) => VendorProfile(
        shopName: json['shop_name'] as String? ?? '',
        verificationStatus: json['verification_status'] as String? ?? 'pending',
        rating: (json['rating'] as num?)?.toDouble(),
      );
}

/// Expert profile, present only when [AppUser.role] is [Role.expert].
@immutable
class ExpertProfile {
  const ExpertProfile({this.specialization, this.certification});

  final String? specialization;
  final String? certification;

  factory ExpertProfile.fromJson(Map<String, dynamic> json) => ExpertProfile(
        specialization: json['specialization'] as String?,
        certification: json['certification'] as String?,
      );
}

/// The signed-in user.
///
/// Mirrors the `User object` in `backend/docs/API_SPEC.md` §1 exactly — field
/// names stay snake_case on the wire and camelCase in Dart, and nothing is
/// derived here that the server is the authority on (role, status).
@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.mobile,
    required this.role,
    required this.status,
    this.district,
    this.farmSize,
    this.cropPreferences = const [],
    this.language = 'bn',
    this.highContrast = false,
    this.voiceMode = false,
    this.vendor,
    this.expert,
  });

  final String id;
  final String name;

  /// Kept whole for the owner's own profile and their own orders only. Never
  /// logged (doc 04, "never in logs").
  final String mobile;

  final Role role;
  final AccountStatus status;
  final String? district;
  final double? farmSize;
  final List<CropType> cropPreferences;
  final String language;
  final bool highContrast;
  final bool voiceMode;
  final VendorProfile? vendor;
  final ExpertProfile? expert;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first.characters.first;
    if (parts.length == 1) return first;
    // Two Bangla graphemes can read as a different word (`সে` + `বে`), so a
    // Bangla name gets one mark; English keeps the familiar two letters.
    final last = parts.last.characters.first;
    return RegExp(r'[\u0980-\u09FF]').hasMatch(first) ? first : first + last;
  }

  /// Any account the admin has not approved yet sees the waiting screen rather
  /// than its shell. Vendors and experts keep their A7 behaviour; farmers are
  /// included because the same approval queue now covers every registration
  /// (an admin can auto-approve farmers from the platform settings).
  bool get needsApproval =>
      role != Role.admin && status == AccountStatus.pending;

  bool get isSuspended => status == AccountStatus.suspended;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        mobile: json['mobile'] as String? ?? '',
        role: Role.fromWire(json['role'] as String?),
        status: AccountStatus.fromWire(json['status'] as String?),
        district: json['district'] as String?,
        farmSize: (json['farm_size'] as num?)?.toDouble(),
        cropPreferences: ((json['crop_preferences'] as List<dynamic>?) ?? [])
            .map((e) => CropType.fromWire(e as String?))
            .whereType<CropType>()
            .toList(),
        language: json['language'] as String? ?? 'bn',
        highContrast: json['high_contrast'] as bool? ?? false,
        voiceMode: json['voice_mode'] as bool? ?? false,
        vendor: json['vendor'] == null
            ? null
            : VendorProfile.fromJson(json['vendor'] as Map<String, dynamic>),
        expert: json['expert'] == null
            ? null
            : ExpertProfile.fromJson(json['expert'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'mobile': mobile,
        'role': role.wire,
        'status': status.wire,
        'district': district,
        'farm_size': farmSize,
        'crop_preferences': cropPreferences.map((c) => c.wire).toList(),
        'language': language,
        'high_contrast': highContrast,
        'voice_mode': voiceMode,
        if (vendor != null)
          'vendor': {
            'shop_name': vendor!.shopName,
            'verification_status': vendor!.verificationStatus,
            'rating': vendor!.rating,
          },
        if (expert != null)
          'expert': {
            'specialization': expert!.specialization,
            'certification': expert!.certification,
          },
      };

  AppUser copyWith({
    String? name,
    String? district,
    double? farmSize,
    List<CropType>? cropPreferences,
    String? language,
    bool? highContrast,
    bool? voiceMode,
    AccountStatus? status,
  }) =>
      AppUser(
        id: id,
        name: name ?? this.name,
        mobile: mobile,
        role: role,
        status: status ?? this.status,
        district: district ?? this.district,
        farmSize: farmSize ?? this.farmSize,
        cropPreferences: cropPreferences ?? this.cropPreferences,
        language: language ?? this.language,
        highContrast: highContrast ?? this.highContrast,
        voiceMode: voiceMode ?? this.voiceMode,
        vendor: vendor,
        expert: expert,
      );
}
