import '../models/diagnosis.dart';
import '../models/enums.dart';
import '../models/product.dart';
import '../repositories/diagnosis_repository.dart';
import 'api_client.dart';

class RemoteDiagnosisRepository implements DiagnosisRepository {
  RemoteDiagnosisRepository(this._client);

  final ApiClient _client;

  @override
  Future<Diagnosis> submit(
    PhotoUpload photo, {
    required String clientUuid,
    CropType? crop,
  }) async {
    final fields = <String, String>{
      'client_uuid': clientUuid,
    };
    if (crop != null) {
      fields['crop'] = crop.wire;
    }

    final response = await _client.multipartPost(
      '/diagnosis/scan',
      fileBytes: photo.bytes,
      filename: photo.filename,
      fieldName: 'image',
      fields: fields,
    );

    final data = response['data'] as Map<String, dynamic>? ?? response;
    return Diagnosis.fromJson(data);
  }

  @override
  Future<List<Diagnosis>> history({int page = 1}) async {
    final response = await _client.get(
      '/diagnosis/history',
      query: {'page': '$page', 'limit': '$kDiagnosisPageSize'},
    );

    final list = (response['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => Diagnosis.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Diagnosis> detail(String id) async {
    final response = await _client.get('/diagnosis/$id');
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return Diagnosis.fromJson(data);
  }

  @override
  Future<Diagnosis> requestReview(String id) async {
    final response = await _client.post('/diagnosis/$id/review');
    final data = response['data'] as Map<String, dynamic>? ?? response;
    return Diagnosis.fromJson(data);
  }

  @override
  Future<List<Product>> matchedProducts(String diagnosisId) async {
    final response = await _client.get('/products/matched/$diagnosisId');
    final list = (response['data'] as List<dynamic>?) ?? [];
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
