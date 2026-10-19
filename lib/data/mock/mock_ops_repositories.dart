import 'dart:math';

import '../models/diagnosis.dart';
import '../models/enums.dart';
import '../models/growth.dart';
import '../models/ops.dart';
import '../models/product.dart';
import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/expert_repository.dart';
import '../repositories/vendor_repository.dart';
import 'admin_seed.dart';
import 'growth_seed.dart';
import 'mock_repositories.dart';
import 'mock_seed.dart';
import 'ops_seed.dart';

final _random = Random();

String _nowIsoMock() => DateTime.now().toIso8601String();

/// Same 300–1500 ms latency and debug failure rate as the farmer mocks, so the
/// staff screens exercise the same loading and error paths.
Future<void> _tick(MockConfig config) async {
  await Future<void>.delayed(
    Duration(
      milliseconds: MockConfig.minLatency.inMilliseconds +
          _random.nextInt(
            MockConfig.maxLatency.inMilliseconds -
                MockConfig.minLatency.inMilliseconds,
          ),
    ),
  );
  if (config.failRate > 0 && _random.nextDouble() < config.failRate) {
    throw const ApiException(
      code: 'server_error',
      messageKey: 'stateErrorBody',
      statusCode: 500,
    );
  }
}

/// The vendor whose shop the demo vendor account owns (`01711000002`).
const String _kMyVendorId = 'ven-rahim';

Map<String, dynamic> _vendorJson(String id) {
  final v = kVendorSeed.firstWhere((e) => e['id'] == id);
  return {
    'id': v['id'],
    'shop_name': v['shop_name'],
    'verified': v['verification_status'] == 'verified',
    'rating': v['rating'],
  };
}

Map<String, dynamic> _productJson(Map<String, dynamic> seed) => {
      ...seed,
      'in_stock': (seed['stock'] as int) > 0,
      'vendor': _vendorJson(seed['vendor_id'] as String),
    };

List<Product> _myProducts() => kProductSeed
    .where((p) => p['vendor_id'] == _kMyVendorId)
    .map((p) => Product.fromJson(_productJson(p)))
    .toList();

/// Vendor desk: own listings, own orders (with buyer contact) and ratings.
class MockVendorRepository implements VendorRepository {
  MockVendorRepository({MockConfig? config})
      : _config = config ?? MockConfig(),
        _products = _myProducts(),
        _orders = orderSeed(_nowIsoMock()).map(Order.fromJson).toList(),
        _business = vendorBusinessSeed();

  final MockConfig _config;
  final List<Product> _products;
  final List<Order> _orders;
  VendorBusiness _business;

  /// Set by the debug menu and by tests; verification gates the whole desk
  /// (FR-22), so the screen must be exercisable in both states.
  bool verified = true;

  Product _asProduct({
    required String id,
    required String name,
    String? nameBn,
    required String category,
    required int price,
    required int stock,
    String? description,
    String? imageUrl,
  }) =>
      Product(
        id: id,
        name: name,
        nameBn: nameBn,
        category: category,
        price: price,
        stock: stock,
        inStock: stock > 0,
        description: description,
        imageUrl: imageUrl,
        vendor: VendorSummary(
          id: _kMyVendorId,
          shopName: _vendorJson(_kMyVendorId)['shop_name'] as String,
          verified: verified,
          rating: (_vendorJson(_kMyVendorId)['rating'] as num?)?.toDouble(),
        ),
      );

  @override
  Future<VendorDesk> desk() async {
    await _tick(_config);
    final ratings = [
      for (final r in kVendorRatingSeed)
        if (r['vendor_id'] == _kMyVendorId)
          VendorRating(
            rating: r['rating'] as int,
            comment: r['comment'] as String,
            farmerName: r['farmer_name'] as String,
            createdAt: DateTime.now()
                .subtract(Duration(days: r['days_ago'] as int)),
          ),
    ];
    final orders = [
      for (final o in _orders)
        if (o.vendor.id == _kMyVendorId)
          VendorOrder(
            order: o,
            buyerName: _buyer(o.id, 'name') ?? '',
            buyerMobile: _buyer(o.id, 'mobile') ?? '',
            buyerDistrict: _buyer(o.id, 'district') ?? '',
            note: _buyer(o.id, 'note'),
          ),
    ];

    return VendorDesk(
      products: List.unmodifiable(_products),
      orders: List.unmodifiable(orders),
      ratings: ratings,
      ratingCount: 38,
      averageRating: (_vendorJson(_kMyVendorId)['rating'] as num).toDouble(),
    );
  }

  String? _buyer(String orderId, String field) {
    final buyer = kOrderBuyerSeed[orderId];
    final value = buyer?[field];
    return value is String && value.isNotEmpty ? value : null;
  }

  @override
  Future<Product> saveProduct(VendorProductDraft draft) async {
    await _tick(_config);
    if (!verified) {
      throw const ApiException(
        code: 'vendor_not_verified',
        messageKey: 'vendorBlockedBody',
        statusCode: 403,
      );
    }

    final index = draft.id == null
        ? -1
        : _products.indexWhere((p) => p.id == draft.id);
    final product = _asProduct(
      id: draft.id ?? 'prd-new-${DateTime.now().millisecondsSinceEpoch}',
      name: draft.name,
      nameBn: draft.nameBn,
      category: draft.category,
      price: draft.price,
      stock: draft.stock,
      description: draft.description,
      imageUrl: draft.imageUrl,
    );

    if (index < 0) {
      _products.insert(0, product);
    } else {
      _products[index] = product;
    }
    return product;
  }

  @override
  Future<void> setStock(String productId, int stock) async {
    await _tick(_config);
    final index = _products.indexWhere((p) => p.id == productId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final p = _products[index];
    _products[index] = _asProduct(
      id: p.id,
      name: p.name,
      nameBn: p.nameBn,
      category: p.category,
      price: p.price,
      stock: stock,
      description: p.description,
      imageUrl: p.imageUrl,
    );
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _tick(_config);
    _products.removeWhere((p) => p.id == productId);
  }

  @override
  Future<VendorOrder> updateOrderStatus(
    String orderId,
    OrderStatus status, {
    String? reason,
  }) async {
    await _tick(_config);
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final current = _orders[index];
    final allowed = switch (current.status) {
      OrderStatus.pending => const [OrderStatus.confirmed, OrderStatus.rejected],
      OrderStatus.confirmed => const [OrderStatus.shipped],
      OrderStatus.shipped => const [OrderStatus.delivered],
      _ => const <OrderStatus>[],
    };
    if (!allowed.contains(status)) {
      throw const ApiException(
        code: 'invalid_transition',
        messageKey: 'vendorInvalidTransition',
        statusCode: 409,
      );
    }

    final updated = Order(
      id: current.id,
      orderNo: current.orderNo,
      status: status,
      displayStatus: status,
      paymentMode: current.paymentMode,
      placedVia: current.placedVia,
      totalAmount: current.totalAmount,
      items: current.items,
      vendor: current.vendor,
      history: [
        ...current.history,
        OrderStatusEvent(status: status, at: DateTime.now()),
      ],
      createdAt: current.createdAt,
    );
    _orders[index] = updated;

    return VendorOrder(
      order: updated,
      buyerName: _buyer(updated.id, 'name') ?? '',
      buyerMobile: _buyer(updated.id, 'mobile') ?? '',
      buyerDistrict: _buyer(updated.id, 'district') ?? '',
      note: _buyer(updated.id, 'note'),
    );
  }

  @override
  Future<VendorBusiness> business() async {
    await _tick(_config);
    return _business;
  }

  @override
  Future<VendorCustomer> saveCustomerNote(
    String customerId,
    String note,
  ) async {
    await _tick(_config);
    return _updateCustomer(customerId, (c) => c.copyWith(note: note));
  }

  @override
  Future<VendorCustomer> setFollowUp(
    String customerId,
    bool followUp,
  ) async {
    await _tick(_config);
    return _updateCustomer(customerId, (c) => c.copyWith(followUp: followUp));
  }

  VendorCustomer _updateCustomer(
    String customerId,
    VendorCustomer Function(VendorCustomer) update,
  ) {
    final index = _business.customers.indexWhere((c) => c.id == customerId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final customers = [..._business.customers];
    final updated = update(customers[index]);
    customers[index] = updated;
    _business = VendorBusiness(
      week: _business.week,
      revenue30: _business.revenue30,
      profit30: _business.profit30,
      commission30: _business.commission30,
      pendingPayout: _business.pendingPayout,
      storeVisits: _business.storeVisits,
      orders30: _business.orders30,
      payouts: _business.payouts,
      topProducts: _business.topProducts,
      customers: List.unmodifiable(customers),
    );
    return updated;
  }
}

/// Expert desk: the review queue, the news pipeline and the knowledge base.
class MockExpertRepository implements ExpertRepository {
  MockExpertRepository({MockConfig? config})
      : _config = config ?? MockConfig(),
        _cases = expertReviewSeed(_nowIsoMock())
            .map(ReviewCase.fromJson)
            .toList(),
        _drafts =
            newsDraftSeed(_nowIsoMock()).map(NewsDraft.fromJson).toList(),
        _knowledge = [
          for (final k in kKnowledgeSeed)
            KnowledgeEntry.fromJson({
              ...k,
              'disease_name': kDiseaseSeed.firstWhere(
                (d) => d['id'] == k['disease_id'],
              )['name_bn'],
              'updated_at': DateTime.now()
                  .subtract(Duration(days: k['updated_days_ago'] as int))
                  .toIso8601String(),
            }),
        ],
        _desk = expertDeskSeed();

  final MockConfig _config;
  ExpertDesk _desk;
  final List<ReviewCase> _cases;
  final List<NewsDraft> _drafts;
  final List<KnowledgeEntry> _knowledge;

  /// Sources an expert suggested this session, so the screen can honestly say
  /// the suggestion was recorded (the admin console owns the real list).
  final List<({String name, String url, String? note})> suggestions = [];

  @override
  Future<List<ReviewCase>> reviews() async {
    await _tick(_config);
    return List.unmodifiable(_cases);
  }

  @override
  Future<List<Disease>> diseasesFor(CropType? crop) async {
    await _tick(_config);
    return [
      for (final d in kDiseaseSeed)
        if (crop == null || d['crop'] == crop.wire)
          Disease.fromJson({
            'id': d['id'],
            'name_bn': d['name_bn'],
            'name_en': d['name_en'],
            'is_healthy': d['is_healthy'],
          }),
    ];
  }

  @override
  Future<ReviewCase> resolve(
    String reviewId, {
    required String diseaseId,
    String? note,
  }) async {
    await _tick(_config);
    final disease = kDiseaseSeed.firstWhere((d) => d['id'] == diseaseId);
    return _replace(
      reviewId,
      (c) => ReviewCase(
        id: c.id,
        diagnosisId: c.diagnosisId,
        farmerName: c.farmerName,
        farmerDistrict: c.farmerDistrict,
        crop: c.crop,
        confidence: c.confidence,
        createdAt: c.createdAt,
        resolved: true,
        top3: c.top3,
        resolutionDiseaseId: diseaseId,
        resolutionDiseaseName: disease['name_bn'] as String,
        note: note,
      ),
    );
  }

  @override
  Future<ReviewCase> needsRetake(String reviewId, {required String note}) async {
    await _tick(_config);
    return _replace(
      reviewId,
      (c) => ReviewCase(
        id: c.id,
        diagnosisId: c.diagnosisId,
        farmerName: c.farmerName,
        farmerDistrict: c.farmerDistrict,
        crop: c.crop,
        confidence: c.confidence,
        createdAt: c.createdAt,
        resolved: true,
        top3: c.top3,
        note: note,
        needsRetake: true,
      ),
    );
  }

  ReviewCase _replace(
    String reviewId,
    ReviewCase Function(ReviewCase) update,
  ) {
    final index = _cases.indexWhere((c) => c.id == reviewId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final updated = update(_cases[index]);
    _cases[index] = updated;
    return updated;
  }

  @override
  Future<List<NewsDraft>> news() async {
    await _tick(_config);
    return List.unmodifiable(_drafts);
  }

  @override
  Future<NewsDraft> saveDraft(NewsDraft draft) async {
    await _tick(_config);
    // Editing a "needs writing" item is what turns it into a draft — the
    // pipeline in API_SPEC §9 has no other way out of that state.
    final next = draft.copyWith(
      status: draft.status == DraftStatus.needsWriting
          ? DraftStatus.draft
          : draft.status,
    );
    final index = _drafts.indexWhere((d) => d.id == draft.id);
    if (index < 0) {
      _drafts.insert(0, next);
    } else {
      _drafts[index] = next;
    }
    return next;
  }

  @override
  Future<NewsDraft> approveNews(String draftId, {required bool urgent}) async {
    await _tick(_config);
    return _replaceDraft(
      draftId,
      (d) => d.copyWith(
        status: DraftStatus.published,
        urgent: urgent,
        publishedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<NewsDraft> rejectNews(
    String draftId, {
    required String reason,
  }) async {
    await _tick(_config);
    return _replaceDraft(
      draftId,
      (d) => d.copyWith(status: DraftStatus.rejected, rejectReason: reason),
    );
  }

  @override
  Future<NewsDraft> addManualNews({
    required String title,
    required String summary,
    required NewsCategory category,
    required CropType crop,
    required Severity severity,
    required String advisedAction,
  }) async {
    await _tick(_config);
    final draft = NewsDraft(
      id: 'draft-new-${DateTime.now().millisecondsSinceEpoch}',
      status: DraftStatus.draft,
      titleBn: title,
      summaryBn: summary,
      advisedActionBn: advisedAction,
      category: category,
      crop: crop,
      severity: severity,
      affectedDistricts: const [],
      sourceName: 'AgriSense বিশেষজ্ঞ',
      sourceUrl: '',
      updatedAt: DateTime.now(),
    );
    _drafts.insert(0, draft);
    return draft;
  }

  @override
  Future<void> suggestSource({
    required String name,
    required String url,
    String? note,
  }) async {
    await _tick(_config);
    suggestions.add((name: name, url: url, note: note));
  }

  NewsDraft _replaceDraft(String draftId, NewsDraft Function(NewsDraft) update) {
    final index = _drafts.indexWhere((d) => d.id == draftId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final updated = update(_drafts[index]);
    _drafts[index] = updated;
    return updated;
  }

  @override
  Future<List<KnowledgeEntry>> knowledge({String query = ''}) async {
    await _tick(_config);
    final needle = query.trim();
    if (needle.isEmpty) return List.unmodifiable(_knowledge);
    return _knowledge
        .where(
          (k) =>
              k.diseaseName.contains(needle) ||
              k.protocolBn.contains(needle) ||
              k.source.contains(needle),
        )
        .toList(growable: false);
  }

  @override
  Future<KnowledgeEntry> saveKnowledge({
    required String diseaseId,
    required String protocolBn,
    required String source,
    required String safetyNoteBn,
  }) async {
    await _tick(_config);
    final disease = kDiseaseSeed.firstWhere((d) => d['id'] == diseaseId);
    final index = _knowledge.indexWhere((k) => k.diseaseId == diseaseId);
    final previous = index < 0 ? null : _knowledge[index];

    final entry = KnowledgeEntry(
      id: previous?.id ?? 'kb-new-${DateTime.now().millisecondsSinceEpoch}',
      diseaseId: diseaseId,
      diseaseName: disease['name_bn'] as String,
      crop: CropType.fromWire(disease['crop'] as String?),
      protocolBn: protocolBn,
      source: source,
      safetyNoteBn: safetyNoteBn,
      version: (previous?.version ?? 0) + 1,
      updatedAt: DateTime.now(),
      // Long-lived on purpose: the screen states that a reindex was queued
      // rather than pretending it finished instantly.
      reindexQueued: true,
    );
    if (previous == null) {
      _knowledge.insert(0, entry);
    } else {
      _knowledge[index] = entry;
    }
    return entry;
  }

  @override
  Future<ExpertDesk> desk() async {
    await _tick(_config);
    return _desk;
  }

  @override
  Future<ExpertArticle> toggleLike(String articleId) async {
    await _tick(_config);
    final article = _article(articleId);
    return _replaceArticle(
      article.copyWith(
        liked: !article.liked,
        likes: article.likes + (article.liked ? -1 : 1),
      ),
    );
  }

  @override
  Future<ExpertArticle> toggleSaved(String articleId) async {
    await _tick(_config);
    final article = _article(articleId);
    return _replaceArticle(article.copyWith(saved: !article.saved));
  }

  @override
  Future<ExpertArticle> rateArticle(String articleId, int rating) async {
    await _tick(_config);
    final article = _article(articleId);
    final nextCount = article.ratingCount + 1;
    final average =
        ((article.rating * article.ratingCount) + rating) / nextCount;
    return _replaceArticle(
      article.copyWith(
        rating: double.parse(average.toStringAsFixed(2)),
        ratingCount: nextCount,
      ),
    );
  }

  @override
  Future<ExpertArticle> commentOnArticle(
    String articleId,
    String body,
  ) async {
    await _tick(_config);
    final article = _article(articleId);
    return _replaceArticle(
      article.copyWith(
        comments: [
          ...article.comments,
          ArticleComment(
            id: 'cm-${DateTime.now().microsecondsSinceEpoch}',
            authorName: 'ড. মাহবুবুর রহমান',
            body: body,
            at: DateTime.now(),
            isExpert: true,
          ),
        ],
      ),
    );
  }

  @override
  Future<ExpertArticle> publishArticle({
    required String title,
    required String summary,
    required String body,
    required String crop,
  }) async {
    await _tick(_config);
    final article = ExpertArticle(
      id: 'art-${DateTime.now().microsecondsSinceEpoch}',
      title: title,
      summary: summary,
      body: body,
      authorName: 'ড. মাহবুবুর রহমান',
      authorTitle: 'ধান ও সবজির রোগ বিশেষজ্ঞ',
      crop: crop,
      publishedAt: DateTime.now(),
      likes: 0,
      views: 0,
      rating: 0,
      ratingCount: 0,
      comments: const [],
      coverTone: _desk.articles.length % 4,
      mine: true,
    );
    _desk = ExpertDesk(
      articles: [article, ..._desk.articles],
      questions: _desk.questions,
      plans: _desk.plans,
      bookings: _desk.bookings,
      peers: _desk.peers,
      rating: _desk.rating,
      followers: _desk.followers,
      subscribers: _desk.subscribers,
      earnings: _desk.earnings,
      responseMinutes: _desk.responseMinutes,
    );
    return article;
  }

  @override
  Future<ExpertQuestion> answerQuestion(
    String questionId,
    String reply,
  ) async {
    await _tick(_config);
    final index = _desk.questions.indexWhere((q) => q.id == questionId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final questions = [..._desk.questions];
    final updated =
        questions[index].copyWith(answered: true, reply: reply);
    questions[index] = updated;
    _desk = ExpertDesk(
      articles: _desk.articles,
      questions: questions,
      plans: _desk.plans,
      bookings: _desk.bookings,
      peers: _desk.peers,
      rating: _desk.rating,
      followers: _desk.followers,
      subscribers: _desk.subscribers,
      earnings: _desk.earnings,
      responseMinutes: _desk.responseMinutes,
    );
    return updated;
  }

  @override
  Future<ConsultationPlan> togglePlan(String planId, bool active) async {
    await _tick(_config);
    final index = _desk.plans.indexWhere((p) => p.id == planId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final plans = [..._desk.plans];
    final updated = plans[index].copyWith(active: active);
    plans[index] = updated;
    _desk = ExpertDesk(
      articles: _desk.articles,
      questions: _desk.questions,
      plans: plans,
      bookings: _desk.bookings,
      peers: _desk.peers,
      rating: _desk.rating,
      followers: _desk.followers,
      subscribers: _desk.subscribers,
      earnings: _desk.earnings,
      responseMinutes: _desk.responseMinutes,
    );
    return updated;
  }

  @override
  Future<ExpertPeer> toggleConnect(String peerId) async {
    await _tick(_config);
    final index = _desk.peers.indexWhere((p) => p.id == peerId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final peers = [..._desk.peers];
    final updated = peers[index].copyWith(connected: !peers[index].connected);
    peers[index] = updated;
    _desk = ExpertDesk(
      articles: _desk.articles,
      questions: _desk.questions,
      plans: _desk.plans,
      bookings: _desk.bookings,
      peers: peers,
      rating: _desk.rating,
      followers: _desk.followers,
      subscribers: _desk.subscribers,
      earnings: _desk.earnings,
      responseMinutes: _desk.responseMinutes,
    );
    return updated;
  }

  ExpertArticle _article(String id) {
    for (final article in _desk.articles) {
      if (article.id == id) return article;
    }
    throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
  }

  ExpertArticle _replaceArticle(ExpertArticle updated) {
    _desk = ExpertDesk(
      articles: [
        for (final article in _desk.articles)
          article.id == updated.id ? updated : article,
      ],
      questions: _desk.questions,
      plans: _desk.plans,
      bookings: _desk.bookings,
      peers: _desk.peers,
      rating: _desk.rating,
      followers: _desk.followers,
      subscribers: _desk.subscribers,
      earnings: _desk.earnings,
      responseMinutes: _desk.responseMinutes,
    );
    return updated;
  }
}

/// Admin console: vendors, users, news sources, schedule and logs.
class MockAdminRepository implements AdminRepository {
  MockAdminRepository({MockConfig? config})
      : _config = config ?? MockConfig(),
        _vendors =
            adminVendorSeed(_nowIsoMock()).map(AdminVendor.fromJson).toList(),
        _users =
            adminUserSeed(_nowIsoMock()).map(PlatformUser.fromJson).toList(),
        _sources =
            newsSourceSeed(_nowIsoMock()).map(ManagedNewsSource.fromJson).toList(),
        _logs = opsLogSeed(_nowIsoMock()).map(OpsLogEntry.fromJson).toList(),
        _products = [...adminProductSeed()],
        _content = [...adminContentSeed()],
        _settings = adminSettingsSeed(),
        _allOrders = orderSeed(_nowIsoMock()).map(Order.fromJson).toList();

  final MockConfig _config;
  final List<AdminVendor> _vendors;
  final List<PlatformUser> _users;
  final List<ManagedNewsSource> _sources;
  final List<OpsLogEntry> _logs;
  final List<AdminProduct> _products;
  final List<AdminContent> _content;
  final List<Order> _allOrders;
  AdminSettings _settings;

  int _intervalHours = 6;
  bool _scheduleEnabled = true;

  @override
  Future<List<AdminVendor>> vendors({String? status}) async {
    await _tick(_config);
    if (status == null) return List.unmodifiable(_vendors);
    return _vendors.where((v) => v.status == status).toList(growable: false);
  }

  @override
  Future<AdminVendor> verifyVendor(String vendorId) async =>
      _updateVendor(vendorId, 'verified', null);

  @override
  Future<AdminVendor> rejectVendor(
    String vendorId, {
    required String reason,
  }) async =>
      _updateVendor(vendorId, 'rejected', reason);

  @override
  Future<AdminVendor> suspendVendor(
    String vendorId, {
    required String reason,
  }) async =>
      _updateVendor(vendorId, 'suspended', reason);

  Future<AdminVendor> _updateVendor(
    String vendorId,
    String status,
    String? reason,
  ) async {
    await _tick(_config);
    final index = _vendors.indexWhere((v) => v.id == vendorId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final updated = _vendors[index].copyWith(status: status, reason: reason);
    _vendors[index] = updated;
    _logs.insert(
      0,
      OpsLogEntry(
        id: 'log-${DateTime.now().microsecondsSinceEpoch}',
        type: OpsLogType.audit,
        message: 'অ্যাডমিন “${updated.shopName}” বিক্রেতার অবস্থা '
            '“$status” করেছেন।',
        at: DateTime.now(),
      ),
    );
    return updated;
  }

  @override
  Future<List<PlatformUser>> users({
    String query = '',
    Role? role,
    AccountStatus? status,
  }) async {
    await _tick(_config);
    final needle = query.trim();
    return _users
        .where((u) => role == null || u.role == role)
        .where((u) => status == null || u.status == status)
        .where(
          (u) =>
              needle.isEmpty ||
              u.name.contains(needle) ||
              u.mobile.contains(needle) ||
              u.district.contains(needle),
        )
        .toList(growable: false);
  }

  @override
  Future<PlatformUser> setUserStatus(
    String userId,
    AccountStatus status, {
    String? reason,
  }) async {
    await _tick(_config);
    final index = _users.indexWhere((u) => u.id == userId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final current = _users[index];
    final updated = PlatformUser(
      id: current.id,
      name: current.name,
      mobile: current.mobile,
      role: current.role,
      status: status,
      district: current.district,
      joinedAt: current.joinedAt,
      reason: reason,
    );
    _users[index] = updated;
    return updated;
  }

  @override
  Future<List<ManagedNewsSource>> sources() async {
    await _tick(_config);
    return List.unmodifiable(_sources);
  }

  @override
  Future<ManagedNewsSource> saveSource(ManagedNewsSource source) async {
    await _tick(_config);
    final index = _sources.indexWhere((s) => s.id == source.id);
    if (index < 0) {
      _sources.insert(0, source);
    } else {
      _sources[index] = source;
    }
    return source;
  }

  @override
  Future<ManagedNewsSource> toggleSource(String sourceId, bool active) async {
    await _tick(_config);
    final index = _sources.indexWhere((s) => s.id == sourceId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final updated = _sources[index].copyWith(active: active);
    _sources[index] = updated;
    return updated;
  }

  @override
  Future<void> removeSource(String sourceId) async {
    await _tick(_config);
    _sources.removeWhere((s) => s.id == sourceId);
  }

  @override
  Future<CollectionSchedule> schedule() async {
    await _tick(_config);
    return CollectionSchedule(
      intervalHours: _intervalHours,
      enabled: _scheduleEnabled,
      nextRunAt: _nextRun(),
    );
  }

  @override
  Future<CollectionSchedule> setSchedule({
    required int intervalHours,
    required bool enabled,
  }) async {
    await _tick(_config);
    _intervalHours = intervalHours.clamp(1, 24);
    _scheduleEnabled = enabled;
    return CollectionSchedule(
      intervalHours: _intervalHours,
      enabled: enabled,
      nextRunAt: _nextRun(),
    );
  }

  DateTime _nextRun() => DateTime.now().add(Duration(hours: _intervalHours));

  @override
  Future<OpsLogEntry> runNow() async {
    await _tick(_config);
    var collected = 0;
    for (var i = 0; i < _sources.length; i++) {
      final source = _sources[i];
      if (!source.active) continue;
      // The one source that failed last time keeps failing: a collector that
      // suddenly works would hide the error path this screen has to show.
      final ok = source.id != 'src-bari';
      final items = ok ? 1 : 0;
      collected += items;
      _sources[i] = source.copyWith(
        lastRunAt: DateTime.now(),
        lastRunOk: ok,
        itemsLastRun: items,
        lastError: ok ? null : source.lastError,
      );
    }

    final entry = OpsLogEntry(
      id: 'log-${DateTime.now().microsecondsSinceEpoch}',
      type: OpsLogType.collection,
      message: 'সংগ্রহ এখনই চালানো হয়েছে — $collectedটি নতুন খবর পাওয়া গেছে।',
      at: DateTime.now(),
    );
    _logs.insert(0, entry);
    return entry;
  }

  @override
  Future<List<OpsLogEntry>> logs({OpsLogType? type}) async {
    await _tick(_config);
    if (type == null) return List.unmodifiable(_logs);
    return _logs.where((l) => l.type == type).toList(growable: false);
  }

  @override
  Future<AdminOverview> overview() async {
    await _tick(_config);
    final pending =
        _users.where((u) => u.status == AccountStatus.pending).length +
            _vendors.where((v) => v.isPending).length;
    final issues = _sources
        .where((s) => s.active && s.lastRunOk == false)
        .length;
    return adminOverviewSeed(pending, issues);
  }

  @override
  Future<List<AdminProduct>> products() async {
    await _tick(_config);
    return List.unmodifiable(_products);
  }

  @override
  Future<AdminProduct> setProductHidden(
    String productId,
    bool hidden,
  ) async {
    await _tick(_config);
    final index = _products.indexWhere((p) => p.id == productId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final updated = _products[index].copyWith(hidden: hidden);
    _products[index] = updated;
    _logs.insert(
      0,
      OpsLogEntry(
        id: 'log-${DateTime.now().microsecondsSinceEpoch}',
        type: OpsLogType.audit,
        message: hidden
            ? 'অ্যাডমিন “${updated.name}” পণ্যটি দোকান থেকে লুকিয়েছেন।'
            : 'অ্যাডমিন “${updated.name}” পণ্যটি আবার প্রকাশ করেছেন।',
        at: DateTime.now(),
      ),
    );
    return updated;
  }

  @override
  Future<List<Order>> allOrders() async {
    await _tick(_config);
    return List.unmodifiable(_allOrders);
  }

  @override
  Future<List<AdminContent>> content() async {
    await _tick(_config);
    return List.unmodifiable(_content);
  }

  @override
  Future<AdminContent> setContentHidden(
    String contentId,
    bool hidden,
  ) async {
    await _tick(_config);
    final index = _content.indexWhere((c) => c.id == contentId);
    if (index < 0) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final updated = _content[index].copyWith(hidden: hidden);
    _content[index] = updated;
    _logs.insert(
      0,
      OpsLogEntry(
        id: 'log-${DateTime.now().microsecondsSinceEpoch}',
        type: OpsLogType.audit,
        message: hidden
            ? 'অ্যাডমিন “${updated.title}” কনটেন্টটি ফিড থেকে সরিয়েছেন।'
            : 'অ্যাডমিন “${updated.title}” কনটেন্টটি আবার প্রকাশ করেছেন।',
        at: DateTime.now(),
      ),
    );
    return updated;
  }

  @override
  Future<AdminSettings> settings() async {
    await _tick(_config);
    return _settings;
  }

  @override
  Future<AdminSettings> saveSettings(AdminSettings settings) async {
    await _tick(_config);
    _settings = settings;
    _logs.insert(
      0,
      OpsLogEntry(
        id: 'log-${DateTime.now().microsecondsSinceEpoch}',
        type: OpsLogType.audit,
        message: 'অ্যাডমিন প্ল্যাটফর্ম সেটিংস পরিবর্তন করেছেন '
            '(কমিশন ${settings.commissionPercent}%)।',
        at: DateTime.now(),
      ),
    );
    return _settings;
  }
}
