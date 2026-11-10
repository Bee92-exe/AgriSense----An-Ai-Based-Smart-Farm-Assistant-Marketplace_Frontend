import '../models/enums.dart';
import '../models/product.dart';
import '../repositories/market_repository.dart';
import 'api_client.dart';

/// Haat_Bazar against the real API.
///
/// Every amount here comes from the server already rounded to integer taka; the
/// device never recalculates a price (T-D3).
class RemoteMarketRepository implements MarketRepository {
  RemoteMarketRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<Product>> products({ProductQuery? query}) async {
    final q = query;
    final params = <String, String>{
      if (q?.text != null && q!.text!.isNotEmpty) 'search': q.text!,
      if (q?.category != null && q!.category!.isNotEmpty) 'category': q.category!,
      if (q?.priceMin != null) 'price_min': '${q!.priceMin}',
      if (q?.priceMax != null) 'price_max': '${q!.priceMax}',
      if (q?.inStockOnly ?? false) 'in_stock': 'true',
      'page': '${q?.page ?? 1}',
    };

    final response = await _client.get(
      '/products',
      query: params,
      auth: false,
    );
    final list = (response['products'] as List<dynamic>?) ?? const [];
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Product> product(String id) async {
    final response = await _client.get('/products/$id', auth: false);
    final data = response['product'] as Map<String, dynamic>? ?? response;
    return Product.fromJson(data);
  }

  @override
  Future<List<String>> categories() async {
    final response = await _client.get('/products/categories', auth: false);
    return ((response['categories'] as List<dynamic>?) ?? const [])
        .map((e) => e.toString())
        .toList();
  }

  @override
  Future<Order> placeOrder(PlaceOrderRequest request) async {
    final response = await _client.post(
      '/orders',
      body: {
        'client_uuid': request.clientUuid,
        'items': request.items
            .map((item) => {'product_id': item.productId, 'quantity': item.quantity})
            .toList(),
        'payment_mode': request.paymentMode,
        'placed_via': request.placedVia.wire,
        if (request.note != null && request.note!.isNotEmpty) 'note': request.note,
      },
    );
    final data = response['order'] as Map<String, dynamic>? ?? response;
    return Order.fromJson(data);
  }

  @override
  Future<List<Order>> orders({OrderStatus? status}) async {
    final response = await _client.get(
      '/orders',
      query: status == null ? null : {'status': status.wire},
    );
    final list = (response['orders'] as List<dynamic>?) ?? const [];
    return list
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Order> order(String id) async {
    final response = await _client.get('/orders/$id');
    final data = response['order'] as Map<String, dynamic>? ?? response;
    return Order.fromJson(data);
  }

  @override
  Future<Order> cancelOrder(String id) async {
    final response = await _client.post('/orders/$id/cancel');
    final data = response['order'] as Map<String, dynamic>? ?? response;
    return Order.fromJson(data);
  }

  @override
  Future<Invoice> invoice(String orderId) async {
    final response = await _client.get('/orders/$orderId/invoice');
    final data = response['invoice'] as Map<String, dynamic>? ?? response;
    return Invoice.fromJson(data);
  }

  @override
  Future<void> rateVendor({
    required String vendorId,
    required int rating,
    String? comment,
  }) async {
    await _client.post(
      '/vendors/$vendorId/rating',
      body: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }
}
