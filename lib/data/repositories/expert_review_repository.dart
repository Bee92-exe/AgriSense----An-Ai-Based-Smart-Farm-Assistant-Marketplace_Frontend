import '../models/ops.dart';

/// The expert review slice that the backend actually owns.
abstract interface class ExpertReviewRepository {
  Future<List<ReviewCase>> reviews();

  Future<ReviewCase> resolve(
    String reviewId, {
    required String diseaseId,
    String? diseaseName,
    String? note,
  });

  Future<ReviewCase> needsRetake(String reviewId, {required String note});
}
