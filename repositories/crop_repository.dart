import '../models/crop.dart';
import '../models/enums.dart';

/// Reference data and crop advice (API_SPEC §2 and §5).
///
/// `recommend` is the one call that cannot be faked by a table alone: the real
/// service answers from the crop recommender model plus the district's weather,
/// so the interface carries the three inputs the model needs and nothing else.
abstract interface class CropRepository {
  /// `GET /meta/soil-types` — display strings, like districts.
  Future<List<String>> soilTypes();

  /// `GET /meta/seasons`.
  Future<List<String>> seasons();

  /// `GET /meta/districts` — lives here because this screen is the only one
  /// that needs the list rather than the farmer's own district. The register
  /// form still reads its seed directly, which is the Phase-1 shortcut it
  /// documents.
  Future<List<String>> districts();

  /// `POST /crops/recommend`.
  Future<CropAdvice> recommend({
    required String district,
    required String soilType,
    required String season,
  });

  /// `GET /crops/recommendations` — the ones already asked for.
  Future<List<CropAdvice>> savedRecommendations();

  /// `GET /calendar?crop=`.
  Future<CropCalendar> calendar(CropType crop);
}
