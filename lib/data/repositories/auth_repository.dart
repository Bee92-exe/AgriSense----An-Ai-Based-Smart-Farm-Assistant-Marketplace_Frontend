import '../models/enums.dart';
import '../models/user.dart';

/// An error the UI can show in Bangla.
///
/// Carries a localisation key rather than a sentence so the message follows the
/// user's language, and mirrors the API's error shape (`code`, `message_bn`,
/// `message_en`) so a remote implementation can pass the server's wording
/// straight through without a mapping table.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    this.messageKey,
    this.serverMessageBn,
    this.serverMessageEn,
    this.statusCode,
    this.details = const [],
  });

  /// `validation_error | unauthorized | forbidden | not_found | conflict |
  /// throttled | vendor_not_verified | insufficient_stock | ai_unavailable |
  /// server_error` (API_SPEC "Common codes").
  final String code;

  /// Key into the app's own ARB catalogue, used when the server sent nothing.
  final String? messageKey;

  final String? serverMessageBn;
  final String? serverMessageEn;
  final int? statusCode;

  /// Server field errors from `validation_error`, with `message_bn` already
  /// attached by the backend.
  final List<Map<String, dynamic>> details;

  String? fieldMessage(String field, String locale) {
    for (final detail in details) {
      if (detail['field'] != field) continue;
      final bn = detail['message_bn'] as String?;
      final en = detail['message'] as String?;
      if (locale == 'bn' && bn != null && bn.isNotEmpty) return bn;
      if (en != null && en.isNotEmpty) return en;
      if (bn != null && bn.isNotEmpty) return bn;
    }
    return null;
  }

  /// Server text wins when present: the backend is the authority on why it
  /// refused, and it already localises.
  String message(String locale) {
    if (locale == 'bn' && (serverMessageBn?.isNotEmpty ?? false)) {
      return serverMessageBn!;
    }
    if (locale == 'en' && (serverMessageEn?.isNotEmpty ?? false)) {
      return serverMessageEn!;
    }
    if (locale != 'bn' && (serverMessageBn?.isNotEmpty ?? false)) {
      return serverMessageBn!;
    }
    const fallbacks = <String, (String, String)>{
      'stateErrorBody': (
        'সমস্যা হয়েছে। আবার চেষ্টা করুন।',
        'Something went wrong. Please try again.',
      ),
      'no_products_found': (
        'কোনো পণ্য পাওয়া যায়নি।',
        'No products were found.',
      ),
      'one_vendor_per_order': (
        'একটি অর্ডারে একাধিক দোকানের পণ্য রাখা যাবে না।',
        'An order can contain products from one shop only.',
      ),
      'order_cannot_cancel': (
        'এই অর্ডারটি এখন আর বাতিল করা যাবে না।',
        'This order can no longer be cancelled.',
      ),
      'vendorBlockedBody': (
        'আপনার দোকানটি এখন সীমাবদ্ধ। সহায়তা কেন্দ্রে যোগাযোগ করুন।',
        'Your shop is currently restricted. Please contact support.',
      ),
    };
    final fallback = fallbacks[messageKey];
    if (fallback != null) return locale == 'en' ? fallback.$2 : fallback.$1;
    return locale == 'en'
        ? 'Something went wrong. Please try again.'
        : 'সমস্যা হয়েছে। আবার চেষ্টা করুন।';
  }

  @override
  String toString() => 'ApiException($code)';
}

/// Registration payload. Role-specific extras are nullable because only vendors
/// and experts have them (API_SPEC §1).
class RegisterRequest {
  const RegisterRequest({
    required this.name,
    required this.mobile,
    required this.password,
    required this.role,
    required this.district,
    this.shopName,
    this.licenseNo,
    this.specialization,
    this.certification,
  });

  final String name;
  final String mobile;
  final String password;
  final Role role;
  final String district;
  final String? shopName;
  final String? licenseNo;
  final String? specialization;
  final String? certification;
}

abstract interface class AuthRepository {
  Future<AppUser> login({required String mobile, required String password});

  /// Returns the created user. Vendors and experts come back with
  /// `status = pending` and must not reach their shell yet.
  Future<AppUser> register(RegisterRequest request);

  /// FR-3. Always resolves — the response is deliberately generic so the app
  /// cannot be used to discover whether a number is registered. Until SMS is
  /// configured, development prints the reset code in the API server log.
  Future<void> requestPasswordReset(String mobile);

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  });

  Future<void> logout();

  /// Restores a session from secure storage on cold start, or null.
  Future<AppUser?> restoreSession();
}
