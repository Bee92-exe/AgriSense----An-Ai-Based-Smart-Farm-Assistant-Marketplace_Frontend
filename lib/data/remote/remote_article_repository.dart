import '../models/growth.dart';
import '../repositories/article_repository.dart';
import 'api_client.dart';

/// The advisory feed against the live API.
class RemoteArticleRepository implements ArticleRepository {
  RemoteArticleRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ExpertArticle>> articles({String? crop}) async {
    final response = await _client.get(
      '/articles',
      query: crop == null || crop.isEmpty ? null : {'crop': crop},
    );
    return ((response['articles'] as List<dynamic>?) ?? const [])
        .map((e) => ExpertArticle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ExpertArticle> article(String id) async {
    final response = await _client.get('/articles/$id');
    return ExpertArticle.fromJson(response['article'] as Map<String, dynamic>);
  }

  @override
  Future<ExpertArticle> toggleLike(String id) async =>
      _article(await _client.post('/articles/$id/like'));

  @override
  Future<ExpertArticle> toggleSave(String id) async =>
      _article(await _client.post('/articles/$id/save'));

  @override
  Future<ExpertArticle> rate(String id, int rating) async =>
      _article(await _client.post('/articles/$id/rating', body: {'rating': rating}));

  @override
  Future<ExpertArticle> comment(String id, String body) async =>
      _article(await _client.post('/articles/$id/comments', body: {'body': body}));

  ExpertArticle _article(Map<String, dynamic> response) =>
      ExpertArticle.fromJson(response['article'] as Map<String, dynamic>);

  @override
  Future<void> ask({
    required String question,
    required String crop,
    String mode = 'message',
    bool urgent = false,
  }) async {
    await _client.post('/questions', body: {
      'question': question,
      'crop': crop,
      'mode': mode,
      'urgent': urgent,
    });
  }
}
