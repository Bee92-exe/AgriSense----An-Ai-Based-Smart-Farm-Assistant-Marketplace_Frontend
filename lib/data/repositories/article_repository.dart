import '../models/growth.dart';

/// The farmer's side of the expert advisory feed.
///
/// Reading an article is what a view is, so `article` is the only method that
/// needs a plain read; the rest are the reactions a farmer can have.
abstract interface class ArticleRepository {
  Future<List<ExpertArticle>> articles({String? crop});

  Future<ExpertArticle> article(String id);

  Future<ExpertArticle> toggleLike(String id);

  Future<ExpertArticle> toggleSave(String id);

  Future<ExpertArticle> rate(String id, int rating);

  Future<ExpertArticle> comment(String id, String body);

  /// Sends a question to the expert queue. There is no guarantee of a reply, and
  /// the UI says so rather than promising one.
  Future<void> ask({
    required String question,
    required String crop,
    String mode = 'message',
    bool urgent = false,
  });
}
