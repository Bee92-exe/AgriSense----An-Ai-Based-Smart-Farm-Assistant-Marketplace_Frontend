import '../models/enums.dart';
import '../models/growth.dart';
import '../models/ops.dart';
import '../models/product.dart';

/// The vendor side of Haat_Bazar (API_SPEC §6–§7).
///
/// The vendor is identified by the session on the server, never by an id the
/// app sends — which is why none of these methods takes a vendor id. The mock
/// follows the same shape so the remote implementation cannot quietly differ.
abstract interface class VendorRepository {
  /// Dashboard, products and orders in one call, so the counts on the dashboard
  /// always match the lists behind them.
  Future<VendorDesk> desk();

  /// Creates a listing when [draft] has no id, updates it otherwise.
  Future<Product> saveProduct(VendorProductDraft draft);

  Future<void> setStock(String productId, int stock);

  Future<void> deleteProduct(String productId);

  /// Valid transitions only; the server validates again (API_SPEC §7).
  Future<VendorOrder> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? reason,
  });

  /// Money, payouts, top sellers and the customer book in one call. The CRM has
  /// no endpoint in `API_SPEC` yet; this is the seam the real client fills.
  Future<VendorBusiness> business();

  /// Saves the shop's private note about a customer. Buyer contact is only ever
  /// the vendor's own orders (doc 04), so no customer id comes from the client.
  Future<VendorCustomer> saveCustomerNote(String customerId, String note);

  /// Marks a customer for a follow-up call. The same row carries the note, so a
  /// vendor can leave the reminder with the context that produced it.
  Future<VendorCustomer> setFollowUp(String customerId, bool followUp);
}
