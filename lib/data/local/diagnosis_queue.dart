import '../models/diagnosis.dart';
import '../models/enums.dart';
import '../repositories/auth_repository.dart';
import '../repositories/diagnosis_repository.dart';
import 'pending_diagnosis_store.dart';

/// Sends photos that were captured without a connection.
///
/// This is deliberately not a background scheduler: it runs when the app starts
/// and whenever the caller asks. That keeps the timing understandable on every
/// platform (mobile, desktop, web) without a new dependency, and it matches how
/// a farmer actually retries — by opening the app again.
class DiagnosisQueue {
  DiagnosisQueue({
    required DiagnosisRepository repository,
    required PendingDiagnosisStore store,
  })  : _repository = repository,
        _store = store;

  /// A photo that keeps failing for a non-network reason is retried this many
  /// times and then left in place. Dropping it would silently discard the
  /// farmer's evidence; retrying forever would burn battery on a bad file.
  static const _maxAttempts = 5;

  final DiagnosisRepository _repository;
  final PendingDiagnosisStore _store;

  int get pendingCount => _store.count();

  Future<void> enqueue({
    required PhotoUpload photo,
    required String clientUuid,
    CropType? crop,
  }) =>
      _store.add(
        PendingDiagnosis(
          clientUuid: clientUuid,
          filename: photo.filename,
          mimeType: photo.mimeType,
          bytes: photo.bytes,
          createdAt: DateTime.now(),
          cropWire: crop?.wire,
        ),
      );

  /// Uploads everything it can and returns the diagnoses it obtained.
  ///
  /// A network failure breaks the loop instead of spinning: if the first photo
  /// cannot reach the server, the rest cannot either, and the remaining items
  /// stay queued in their original order.
  Future<List<Diagnosis>> flush() async {
    final pending = _store.all();
    final uploaded = <Diagnosis>[];

    for (final item in pending) {
      if (item.attempts >= _maxAttempts) continue;

      try {
        final diagnosis = await _repository.submit(
          PhotoUpload(
            bytes: item.bytes,
            filename: item.filename,
            mimeType: item.mimeType,
          ),
          clientUuid: item.clientUuid,
          crop: CropType.fromWire(item.cropWire),
        );
        await _store.remove(item.clientUuid);
        uploaded.add(diagnosis);
      } on ApiException catch (error) {
        if (error.code == 'network_error') break;
        await _store.incrementAttempts(item.clientUuid);
      } catch (_) {
        // An unexpected failure on one photo must not block the others.
        await _store.incrementAttempts(item.clientUuid);
      }
    }

    return uploaded;
  }
}
