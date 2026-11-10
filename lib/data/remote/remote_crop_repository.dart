import '../models/crop.dart';
import '../models/enums.dart';
import '../repositories/crop_repository.dart';
import 'api_client.dart';

class RemoteCropRepository implements CropRepository {
  RemoteCropRepository(this._client);

  final ApiClient _client;

  Future<List<String>> _strings(String path, String key) async {
    final response = await _client.get(path);
    return ((response[key] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList();
  }

  @override
  Future<List<String>> soilTypes() => _strings('/meta/soil-types', 'soil_types');

  @override
  Future<List<String>> seasons() => _strings('/meta/seasons', 'seasons');

  @override
  Future<List<String>> districts() => _strings('/meta/districts', 'districts');

  @override
  Future<CropAdvice> recommend({
    required String district,
    required String soilType,
    required String season,
  }) async {
    final response = await _client.post(
      '/crops/recommend',
      body: {'district': district, 'soil_type': soilType, 'season': season},
    );
    final data = response['advice'] as Map<String, dynamic>? ?? const {};
    return CropAdvice.fromJson(data);
  }

  @override
  Future<List<CropAdvice>> savedRecommendations() async {
    final response = await _client.get('/crops/recommendations');
    final list = (response['recommendations'] as List<dynamic>?) ?? const [];
    return list
        .map((e) => CropAdvice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CropCalendar> calendar(CropType crop) async {
    final response = await _client.get(
      '/calendar',
      query: {'crop': crop.wire},
    );
    final data = response['calendar'] as Map<String, dynamic>? ?? const {};
    return CropCalendar.fromJson(data);
  }
}
