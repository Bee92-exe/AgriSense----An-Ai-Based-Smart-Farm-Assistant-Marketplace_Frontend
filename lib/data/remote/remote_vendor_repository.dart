import '../models/enums.dart';
import '../models/growth.dart';
import '../models/ops.dart';
import '../models/product.dart';
import '../repositories/vendor_repository.dart';
import 'api_client.dart';

/// The vendor console against the live API.
///
/// Every call is scoped to the signed-in shop on the server, so no method here
/// sends a vendor id. A 403 means the account has no vendor profile; a 404 on a
/// product or order means it belongs to someone else.
class RemoteVendorRepository implements VendorRepository {
  RemoteVendorRepository(this._client);

  final ApiClient _client;

  @override
  Future<VendorDesk> desk() async {
    final response = await _client.get('/vendor/desk');
    final desk = response['desk'] as Map<String, dynamic>? ?? const {};

    return VendorDesk(
      products: ((desk['products'] as List<dynamic>?) ?? const [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
      orders: ((desk['orders'] as List<dynamic>?) ?? const [])
          .map(_vendorOrder)
          .toList(),
      ratings: ((desk['ratings'] as List<dynamic>?) ?? const [])
          .map((e) {
            final json = e as Map<String, dynamic>;
            return VendorRating(
              rating: (json['rating'] as num?)?.toInt() ?? 0,
              comment: json['comment'] as String? ?? '',
              farmerName: json['farmer_name'] as String? ?? '',
              createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
                  DateTime.now(),
            );
          })
          .toList(),
      ratingCount: (desk['rating_count'] as num?)?.toInt() ?? 0,
      averageRating: (desk['average_rating'] as num?)?.toDouble() ?? 0,
    );
  }

  VendorOrder _vendorOrder(dynamic raw) {
    final json = raw as Map<String, dynamic>;
    return VendorOrder(
      order: Order.fromJson(json['order'] as Map<String, dynamic>),
      buyerName: json['buyer_name'] as String? ?? '',
      buyerMobile: json['buyer_mobile'] as String? ?? '',
      buyerDistrict: json['buyer_district'] as String? ?? '',
      note: json['note'] as String?,
    );
  }

  @override
  Future<Product> saveProduct(VendorProductDraft draft) async {
    final body = <String, dynamic>{
      'name': draft.name,
      'category': draft.category,
      'price': draft.price,
      'stockLevel': draft.stock,
      'description': ?draft.description,
      'imageUrl': ?draft.imageUrl,    };

    final response = draft.id == null
        ? await _client.post('/vendor/products', body: body)
        : await _client.put('/vendor/products/${draft.id}', body: body);

    return Product.fromJson(response['product'] as Map<String, dynamic>);
  }

  @override
  Future<void> setStock(String productId, int stock) async {
    await _client.put(
      '/vendor/products/$productId',
      body: {'stockLevel': stock},
    );
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _client.delete('/vendor/products/$productId');
  }

  @override
  Future<VendorOrder> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? reason,
  }) async {
    final response = await _client.put(
      '/vendor/orders/$orderId/status',
      body: {
        'status': status.wire.toUpperCase(),
        'reason': ?reason,
      },
    );
    return _vendorOrder(response['order']);
  }

  @override
  Future<VendorBusiness> business() async {
    final response = await _client.get('/vendor/business');
    return VendorBusiness.fromJson(
      response['business'] as Map<String, dynamic>? ?? const {},
    );
  }

  @override
  Future<VendorCustomer> saveCustomerNote(
    String customerId,
    String note,
  ) async {
    final response = await _client.put(
      '/vendor/customers/$customerId/note',
      body: {'note': note},
    );
    return VendorCustomer.fromJson(response['customer'] as Map<String, dynamic>);
  }

  @override
  Future<VendorCustomer> setFollowUp(String customerId, bool followUp) async {
    final response = await _client.put(
      '/vendor/customers/$customerId/follow-up',
      body: {'followUp': followUp},
    );
    return VendorCustomer.fromJson(response['customer'] as Map<String, dynamic>);
  }
}
