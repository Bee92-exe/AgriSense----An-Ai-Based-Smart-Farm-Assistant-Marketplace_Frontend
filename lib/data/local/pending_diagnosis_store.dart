import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

/// One leaf photo waiting for a network.
///
/// The bytes live here, not just a path: a farmer who closes the app before the
/// upload succeeds must not lose the photo, and `shared_preferences` is already
/// the app's only durable store (the same one settings use), so this adds no
/// platform dependency and works on web where `dart:io` does not exist.
class PendingDiagnosis {
  const PendingDiagnosis({
    required this.clientUuid,
    required this.filename,
    required this.mimeType,
    required this.bytes,
    required this.createdAt,
    this.cropWire,
    this.attempts = 0,
  });

  /// The upload's idempotency key, created once at capture time. Re-sending the
  /// same photo reuses it, so a retry after a timeout cannot create a duplicate
  /// diagnosis (FR-27).
  final String clientUuid;

  final String filename;
  final String mimeType;
  final Uint8List bytes;
  final DateTime createdAt;

  /// The optional crop hint, kept in wire form so this store does not depend on
  /// the domain enums.
  final String? cropWire;

  final int attempts;

  Map<String, dynamic> toJson() => {
        'client_uuid': clientUuid,
        'filename': filename,
        'mime_type': mimeType,
        'bytes': base64Encode(bytes),
        'created_at': createdAt.toIso8601String(),
        if (cropWire != null) 'crop': cropWire,
        'attempts': attempts,
      };

  factory PendingDiagnosis.fromJson(Map<String, dynamic> json) =>
      PendingDiagnosis(
        clientUuid: json['client_uuid'] as String? ?? '',
        filename: json['filename'] as String? ?? 'leaf.jpg',
        mimeType: json['mime_type'] as String? ?? 'image/jpeg',
        bytes: base64Decode(json['bytes'] as String? ?? ''),
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
        cropWire: json['crop'] as String?,
        attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      );

  PendingDiagnosis withAttempt(int next) => PendingDiagnosis(
        clientUuid: clientUuid,
        filename: filename,
        mimeType: mimeType,
        bytes: bytes,
        createdAt: createdAt,
        cropWire: cropWire,
        attempts: next,
      );
}

/// FIFO-ish list of unsent photos, persisted as one JSON string.
///
/// A single key keeps the store atomic: either the whole queue was written or it
/// was not, so a crash mid-write cannot leave a half-photo behind. The count is
/// small (a farmer's own captures), so re-serialising on every change is fine.
class PendingDiagnosisStore {
  PendingDiagnosisStore(this._prefs);

  static const _key = 'diagnosis_queue_v1';

  final SharedPreferences _prefs;

  /// Corrupt data returns an empty list rather than throwing: failing to parse
  /// a queue is a reason to start a new one, never a reason to block capture.
  List<PendingDiagnosis> all() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return const <PendingDiagnosis>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <PendingDiagnosis>[];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(PendingDiagnosis.fromJson)
          .where((item) => item.clientUuid.isNotEmpty && item.bytes.isNotEmpty)
          .toList();
    } catch (_) {
      return const <PendingDiagnosis>[];
    }
  }

  int count() => all().length;

  Future<void> add(PendingDiagnosis item) async {
    final items = all().where((e) => e.clientUuid != item.clientUuid).toList()
      ..add(item);
    await _write(items);
  }

  Future<void> remove(String clientUuid) async {
    await _write(all().where((e) => e.clientUuid != clientUuid).toList());
  }

  Future<void> incrementAttempts(String clientUuid) async {
    await _write(
      all()
          .map(
            (e) => e.clientUuid == clientUuid ? e.withAttempt(e.attempts + 1) : e,
          )
          .toList(),
    );
  }

  Future<void> _write(List<PendingDiagnosis> items) async {
    await _prefs.setString(
      _key,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }
}
