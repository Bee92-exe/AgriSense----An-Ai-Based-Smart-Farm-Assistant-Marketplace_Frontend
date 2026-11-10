import '../models/enums.dart';
import '../models/news_item.dart';
import '../models/product.dart';
import '../repositories/news_repository.dart';
import 'api_client.dart';

class RemoteNewsRepository implements NewsRepository {
  RemoteNewsRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<NewsItem>> list({NewsQuery? query, int page = 1}) async {
    final q = query;
    final params = <String, String>{
      'page': '$page',
      if (q?.crop != null) 'crop': q!.crop!.wire,
      if (q?.category != null) 'category': q!.category!.wire,
    };

    final response = await _client.get('/news', query: params);
    final items = (response['items'] as List<dynamic>?) ?? const [];
    return items
        .map((e) => NewsItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<NewsItem> detail(String id) async {
    final response = await _client.get('/news/$id');
    final data = response['item'] as Map<String, dynamic>? ?? const {};
    return NewsItem.fromJson(data);
  }

  @override
  Future<void> markRead(String id) => _client.post('/news/$id/read');

  @override
  Future<List<NewsItem>> latest({int limit = 20}) => list(page: 1);

  @override
  Future<List<Product>> productsFor(String newsId) async {
    final response = await _client.get('/news/$newsId/products');
    final products = (response['products'] as List<dynamic>?) ?? const [];
    return products
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// The API filters server-side; this exists so a caller that already has the
/// full list can narrow it without a second request.
List<NewsItem> filterByCategory(List<NewsItem> items, NewsCategory category) =>
    items.where((item) => item.category == category).toList();
