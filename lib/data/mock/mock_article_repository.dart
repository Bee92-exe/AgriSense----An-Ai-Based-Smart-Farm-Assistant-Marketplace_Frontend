import '../models/growth.dart';
import '../repositories/article_repository.dart';
import 'mock_ops_repositories.dart';

/// Test-only feed.
///
/// Automated tests run with `useMockRepositoriesProvider == true`, so the farmer
/// advisory screens need an in-memory source. It reads and writes the same
/// in-memory articles the mock expert desk owns, which keeps the two halves of
/// the demo consistent without a second seed file.
class MockArticleRepository implements ArticleRepository {
  MockArticleRepository({required MockExpertRepository expert}) : _expert = expert;

  final MockExpertRepository _expert;

  @override
  Future<List<ExpertArticle>> articles({String? crop}) async {
    final desk = await _expert.desk();
    if (crop == null || crop.isEmpty) return desk.articles;
    return desk.articles.where((article) => article.crop == crop).toList();
  }

  @override
  Future<ExpertArticle> article(String id) async {
    final all = await articles();
    return all.firstWhere((article) => article.id == id);
  }

  @override
  Future<ExpertArticle> toggleLike(String id) => _expert.toggleLike(id);

  @override
  Future<ExpertArticle> toggleSave(String id) => _expert.toggleSaved(id);

  @override
  Future<ExpertArticle> rate(String id, int rating) =>
      _expert.rateArticle(id, rating);

  @override
  Future<ExpertArticle> comment(String id, String body) =>
      _expert.commentOnArticle(id, body);

  @override
  Future<void> ask({
    required String question,
    required String crop,
    String mode = 'message',
    bool urgent = false,
  }) async {
    // The mock queue has no farmer-submitted items; the caller still gets the
    // same success path so the form behaves identically in tests.
  }
}
