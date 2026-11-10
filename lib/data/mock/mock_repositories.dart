import 'dart:math';

import '../models/crop.dart';
import '../models/diagnosis.dart';
import '../models/enums.dart';
import '../models/news_item.dart';
import '../models/product.dart';
import '../models/voice.dart';
import '../models/weather.dart';
import '../reference/locations.dart';
import '../repositories/auth_repository.dart';
import '../repositories/crop_repository.dart';
import '../repositories/diagnosis_repository.dart';
import '../repositories/market_repository.dart';
import '../repositories/news_repository.dart';
import '../repositories/voice_repository.dart';
import '../repositories/weather_repository.dart';
import 'mock_seed.dart';

/// Switches that make the mock behave like a real, occasionally-flaky server.
///
/// The design system asks for delays and random failures "so error states get
/// built" — an error path that has never been rendered is not an error path that
/// works. [failRate] defaults to 0 so normal use is not frustrating; the debug
/// menu raises it.
class MockConfig {
  MockConfig({this.failRate = 0});

  /// 0.0-1.0 chance that any single call throws.
  double failRate;

  static const Duration minLatency = Duration(milliseconds: 300);
  static const Duration maxLatency = Duration(milliseconds: 1500);
}

final _random = Random();

Future<void> _lag() => Future<void>.delayed(
      Duration(
        milliseconds: MockConfig.minLatency.inMilliseconds +
            _random.nextInt(
              MockConfig.maxLatency.inMilliseconds -
                  MockConfig.minLatency.inMilliseconds,
            ),
      ),
    );

/// Throws when the injected failure rate says so.
///
/// Uses the same [ApiException] shape a real failure would, so an error state
/// built against the mock is exercising the real code path.
Future<void> _maybeFail(MockConfig config) async {
  await _lag();
  if (config.failRate > 0 && _random.nextDouble() < config.failRate) {
    throw const ApiException(
      code: 'server_error',
      messageKey: 'stateErrorBody',
      statusCode: 500,
    );
  }
}

String _nowIso() => DateTime.now().toIso8601String();

class MockDiagnosisRepository implements DiagnosisRepository {
  MockDiagnosisRepository({MockConfig? config})
      : _config = config ?? MockConfig(),
        _history = diagnosisSeed(_nowIso()).map(Diagnosis.fromJson).toList();

  final MockConfig _config;
  final List<Diagnosis> _history;

  /// Photos captured offline. Surfaced in history with a sync chip so the queue
  /// is visible before the upload layer exists (FR-27).
  final List<Diagnosis> _queued = [];

  /// Picks the canned outcome for a crop so all three confidence bands are
  /// reachable from the UI: rice → high, potato → medium, tomato → low.
  Diagnosis _resultFor(CropType? crop, String clientUuid) {
    final template = switch (crop) {
      CropType.rice => diagnosisSeed(_nowIso())[0],
      CropType.potato => diagnosisSeed(_nowIso())[1],
      CropType.tomato => diagnosisSeed(_nowIso())[2],
      null => diagnosisSeed(_nowIso())[_random.nextInt(3)],
    };
    return Diagnosis.fromJson({
      ...template,
      'id': 'dx-${DateTime.now().microsecondsSinceEpoch}',
      'client_uuid': clientUuid,
      'created_at': _nowIso(),
    });
  }

  @override
  Future<Diagnosis> submit(
    PhotoUpload photo, {
    required String clientUuid,
    CropType? crop,
  }) async {
    await _maybeFail(_config);
    final result = _resultFor(crop ?? CropType.rice, clientUuid);
    _history.insert(0, result);
    return result;
  }

  @override
  Future<List<Diagnosis>> history({int page = 1}) async {
    await _maybeFail(_config);
    if (page > 1) return const [];
    return [..._queued, ..._history];
  }

  @override
  Future<Diagnosis> detail(String id) async {
    await _maybeFail(_config);
    for (final d in [..._queued, ..._history]) {
      if (d.id == id) return d;
    }
    throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
  }

  @override
  Future<Diagnosis> requestReview(String id) async {
    await _maybeFail(_config);
    final index = _history.indexWhere((d) => d.id == id);
    if (index == -1) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    final updated = _history[index].copyWith(status: 'pending_review');
    _history[index] = updated;
    return updated;
  }

  @override
  Future<List<Product>> matchedProducts(String diagnosisId) async {
    await _maybeFail(_config);
    final diagnosis = await detail(diagnosisId);
    final diseaseId = diagnosis.disease?.id;
    final productIds = diseaseId == null
        ? <String>[]
        : (kDiseaseProductMap[diseaseId] ?? <String>[]);

    final market = MockMarketRepository(config: _config);
    final all = await market.products();
    return all
        .where((p) => productIds.contains(p.id))
        .map(
          (p) => Product.fromJson({
            'id': p.id,
            'name': p.name,
            'name_bn': p.nameBn,
            'category': p.category,
            'price': p.price,
            'stock': p.stock,
            'in_stock': p.inStock,
            'description': p.description,
            'active_ingredient': p.activeIngredient,
            'target_diseases': p.targetDiseases,
            'vendor': {
              'id': p.vendor.id,
              'shop_name': p.vendor.shopName,
              'verified': p.vendor.verified,
              'rating': p.vendor.rating,
            },
            'match_score': 0.9,
            'match_reason_bn': 'এই রোগের চিকিৎসায় ব্যবহৃত',
          }),
        )
        .toList();
  }

  /// Adds a photo that could not be uploaded. Called by the offline queue.
  Diagnosis enqueueOffline(PhotoUpload photo, String clientUuid, CropType? crop) {
    final pending = Diagnosis(
      id: 'dx-queued-${DateTime.now().microsecondsSinceEpoch}',
      clientUuid: clientUuid,
      status: 'pending_review',
      confidence: 0,
      confidenceLevel: ConfidenceLevel.low,
      createdAt: DateTime.now(),
      crop: crop,
      syncStatus: SyncStatus.queued,
    );
    _queued.insert(0, pending);
    return pending;
  }
}

class MockMarketRepository implements MarketRepository {
  MockMarketRepository({MockConfig? config})
      : _config = config ?? MockConfig(),
        _orders = orderSeed(_nowIso()).map(Order.fromJson).toList();

  final MockConfig _config;
  final List<Order> _orders;

  bool _isVerifiedVendor(String vendorId) {
    final vendor = kVendorSeed.firstWhere(
      (v) => v['id'] == vendorId,
      orElse: () => const {'verification_status': 'pending'},
    );
    return vendor['verification_status'] == 'verified';
  }

  List<Product> get _catalogue => kProductSeed
      // FR-22/acceptance: only verified vendors' products may be listed, and
      // the filter lives here rather than in the UI so no screen can bypass it.
      .where((p) => _isVerifiedVendor(p['vendor_id'] as String))
      .map(
        (p) => Product.fromJson({
          ...p,
          'in_stock': (p['stock'] as num) > 0,
          'vendor': {
            'id': p['vendor_id'],
            'shop_name': kVendorSeed.firstWhere(
              (v) => v['id'] == p['vendor_id'],
            )['shop_name'],
            'verified': true,
            'rating': kVendorSeed.firstWhere(
              (v) => v['id'] == p['vendor_id'],
            )['rating'],
          },
        }),
      )
      .toList();

  @override
  Future<List<Product>> products({ProductQuery? query}) async {
    await _maybeFail(_config);
    final q = query ?? const ProductQuery();
    var items = _catalogue;

    if (q.text != null && q.text!.trim().isNotEmpty) {
      final needle = q.text!.trim().toLowerCase();
      items = items
          .where((p) =>
              p.name.toLowerCase().contains(needle) ||
              (p.nameBn ?? '').contains(q.text!.trim()) ||
              (p.activeIngredient ?? '').toLowerCase().contains(needle))
          .toList();
    }
    if (q.category != null) {
      items = items.where((p) => p.category == q.category).toList();
    }
    if (q.priceMin != null) {
      items = items.where((p) => p.price >= q.priceMin!).toList();
    }
    if (q.priceMax != null) {
      items = items.where((p) => p.price <= q.priceMax!).toList();
    }
    if (q.inStockOnly) {
      items = items.where((p) => p.inStock).toList();
    }
    return items;
  }

  @override
  Future<Product> product(String id) async {
    await _maybeFail(_config);
    final found = _catalogue.where((p) => p.id == id);
    if (found.isEmpty) {
      throw const ApiException(code: 'not_found', messageKey: 'no_products_found');
    }
    return found.first;
  }

  @override
  Future<List<String>> categories() async {
    await _lag();
    return ['seed', 'fertilizer', 'pesticide', 'fungicide', 'equipment'];
  }

  @override
  Future<Order> placeOrder(PlaceOrderRequest request) async {
    await _maybeFail(_config);

    // One vendor per order (API_SPEC §7): mixing vendors is a client bug, so it
    // fails loudly here the same way the server would with a 400.
    final products = <Product>[];
    for (final item in request.items) {
      products.add(await product(item.productId));
    }
    final vendorIds = products.map((p) => p.vendor.id).toSet();
    if (vendorIds.length > 1) {
      throw const ApiException(
        code: 'validation_error',
        messageKey: 'one_vendor_per_order',
        statusCode: 400,
      );
    }

    final items = <OrderItem>[
      for (var i = 0; i < products.length; i++)
        OrderItem(
          productId: products[i].id,
          name: products[i].label('bn'),
          quantity: request.items[i].quantity,
          unitPrice: products[i].price,
          subtotal: products[i].price * request.items[i].quantity,
        ),
    ];

    final order = Order(
      id: 'ord-${DateTime.now().microsecondsSinceEpoch}',
      orderNo: 'AS-2026-${(900000 + _orders.length).toString()}',
      status: OrderStatus.pending,
      displayStatus: OrderStatus.pending,
      paymentMode: request.paymentMode,
      placedVia: request.placedVia,
      totalAmount: items.fold<int>(0, (sum, i) => sum + i.subtotal),
      items: items,
      vendor: products.first.vendor,
      history: [
        OrderStatusEvent(status: OrderStatus.pending, at: DateTime.now()),
      ],
      createdAt: DateTime.now(),
    );
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<List<Order>> orders({OrderStatus? status}) async {
    await _maybeFail(_config);
    if (status == null) return List.unmodifiable(_orders);
    return _orders.where((o) => o.status == status).toList();
  }

  @override
  Future<Order> order(String id) async {
    await _maybeFail(_config);
    final found = _orders.where((o) => o.id == id);
    if (found.isEmpty) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    return found.first;
  }

  @override
  Future<Order> cancelOrder(String id) async {
    await _maybeFail(_config);
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    if (!_orders[index].canCancel) {
      throw const ApiException(
        code: 'invalid_transition',
        messageKey: 'order_cannot_cancel',
        statusCode: 409,
      );
    }
    final original = _orders[index];
    final cancelled = Order(
      id: original.id,
      orderNo: original.orderNo,
      status: OrderStatus.cancelled,
      displayStatus: OrderStatus.cancelled,
      paymentMode: original.paymentMode,
      placedVia: original.placedVia,
      totalAmount: original.totalAmount,
      items: original.items,
      vendor: original.vendor,
      history: [
        ...original.history,
        OrderStatusEvent(status: OrderStatus.cancelled, at: DateTime.now()),
      ],
      createdAt: original.createdAt,
    );
    _orders[index] = cancelled;
    return cancelled;
  }

  @override
  Future<Invoice> invoice(String orderId) async {
    final o = await order(orderId);
    return Invoice(
      orderNo: o.orderNo,
      issuedAt: o.createdAt,
      items: o.items,
      totalAmount: o.totalAmount,
      vendorShopName: o.vendor.shopName,
    );
  }

  @override
  Future<void> rateVendor({
    required String vendorId,
    required int rating,
    String? comment,
  }) async {
    await _maybeFail(_config);
  }
}

class MockNewsRepository implements NewsRepository {
  MockNewsRepository({MockConfig? config}) : _config = config ?? MockConfig();

  final MockConfig _config;
  final Map<String, bool> _readState = {};
  List<NewsItem>? _cache;

  List<NewsItem> get _items => _cache ??= newsSeed(_nowIso())
      .map(NewsItem.fromJson)
      .map((n) => n.copyWith(isRead: _readState[n.id] ?? n.isRead))
      .toList();

  @override
  Future<List<NewsItem>> list({NewsQuery? query, int page = 1}) async {
    await _maybeFail(_config);
    if (page > 1) return const [];
    final q = query ?? const NewsQuery();
    var items = _items;
    if (q.crop != null) {
      items = items.where((n) => n.crop == q.crop).toList();
    }
    if (q.category != null) {
      items = items.where((n) => n.category == q.category).toList();
    }
    // Urgent first, then newest — the ordering the design system implies by
    // putting the urgent banner above everything else.
    items = [...items]..sort((a, b) {
        if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
        return b.publishedAt.compareTo(a.publishedAt);
      });
    return items;
  }

  @override
  Future<NewsItem> detail(String id) async {
    await _maybeFail(_config);
    final found = _items.where((n) => n.id == id);
    if (found.isEmpty) {
      throw const ApiException(code: 'not_found', messageKey: 'stateErrorBody');
    }
    return found.first;
  }

  @override
  Future<void> markRead(String id) async {
    _readState[id] = true;
    _cache = null;
    await _lag();
  }

  @override
  Future<List<NewsItem>> latest({int limit = 20}) async {
    final all = await list();
    return all.take(limit).toList();
  }

  @override
  Future<List<Product>> productsFor(String newsId) async {
    final item = await detail(newsId);
    final market = MockMarketRepository(config: _config);
    final all = await market.products();
    if (item.category == NewsCategory.disease ||
        item.category == NewsCategory.virus) {
      return all.where((p) => p.targetDiseases.isNotEmpty).toList();
    }
    // Pest and nutrient items match on category rather than disease.
    return all
        .where((p) => p.category == 'pesticide' || p.category == 'fertilizer')
        .toList();
  }
}

class MockWeatherRepository implements WeatherRepository {
  MockWeatherRepository({MockConfig? config, String? district})
      : _config = config ?? MockConfig(),
        _district = district ?? 'ঢাকা';

  final MockConfig _config;
  String _district;

  @override
  Future<WeatherReport> report({String? district}) async {
    await _maybeFail(_config);
    if (district != null && district.isNotEmpty) _district = district;
    return WeatherReport.fromJson(weatherSeed(_nowIso(), _district));
  }

  @override
  Future<List<WeatherAlert>> activeAlerts({String? district}) async {
    final report = await this.report(district: district);
    return report.alerts;
  }
}

/// Phase 1 stand-in for `/voice/command` (VOICE_UX.md §8).
///
/// A keyword agent, not a language model: it exists so every state of the voice
/// sheet — understood, unclear, refused, and the confirmation gate — can be
/// built and tested before the AI service exists. Two behaviours are deliberate:
///
/// * An unmatched phrase is a normal `unknown` result with confidence 0, not an
///   exception. "I did not understand" is a state the farmer sees, not a crash.
/// * A phrase that matches loosely (one weak keyword, e.g. just "বাজার") comes
///   back *below* [VoiceCommand.minConfidence] so the unclear path is reachable
///   on purpose rather than only by typing nonsense.
class MockVoiceRepository implements VoiceRepository {
  MockVoiceRepository({MockConfig? config}) : _config = config ?? MockConfig();

  final MockConfig _config;

  /// Screen keywords. Checked in this order, longest phrase first, so
  /// "অর্ডার দেখাও" cannot be eaten by the shorter "অর্ডার করো" rule below.
  static const List<(String, VoiceDestination)> _destinations = [
    ('কৃষি বার্তা', VoiceDestination.krishiBarta),
    ('ফসল পরামর্শ', VoiceDestination.cropAdvice),
    ('সহায়ক', VoiceDestination.assistant),
    ('assistant', VoiceDestination.assistant),
    ('প্রোফাইল', VoiceDestination.profile),
    ('পুরনো স্ক্যান', VoiceDestination.history),
    ('history', VoiceDestination.history),
    ('profile', VoiceDestination.profile),
    ('weather', VoiceDestination.weather),
    ('news', VoiceDestination.krishiBarta),
    ('আবহাওয়া', VoiceDestination.weather),
    ('স্ক্যান', VoiceDestination.diagnosis),
    ('রোগ', VoiceDestination.diagnosis),
    ('খবর', VoiceDestination.krishiBarta),
    ('ইতিহাস', VoiceDestination.history),
    ('বাজার', VoiceDestination.haatBazar),
    ('market', VoiceDestination.haatBazar),
    ('scan', VoiceDestination.diagnosis),
  ];

  /// Product words map to the wire category the catalogue actually uses.
  static const List<(String, String)> _categories = [
    ('ছত্রাকনাশক', 'fungicide'),
    ('ফাঙ্গিসাইড', 'fungicide'),
    ('fungicide', 'fungicide'),
    ('কীটনাশক', 'pesticide'),
    ('pesticide', 'pesticide'),
    ('সার', 'fertilizer'),
    ('fertilizer', 'fertilizer'),
    ('বীজ', 'seed'),
    ('seed', 'seed'),
    ('যন্ত্র', 'equipment'),
    ('equipment', 'equipment'),
  ];

  static const Map<String, int> _numbers = {
    'এক': 1,
    'দুই': 2,
    'দুটো': 2,
    'তিন': 3,
    'চার': 4,
    'পাঁচ': 5,
    'one': 1,
    'two': 2,
    'three': 3,
    'four': 4,
    'five': 5,
  };

  @override
  Future<VoiceCommand> interpret(String transcript) async {
    // Same simulated latency and injectable failure rate as every other mock,
    // so the sheet's error state is reachable without unplugging anything.
    await _maybeFail(_config);
    final text = transcript.trim();
    final lower = text.toLowerCase();

    // A real recogniser returns nothing for silence; treated as unclear rather
    // than as a command.
    if (text.isEmpty) return VoiceCommand.unknown(text);

    // 1. Money first. "রাইস ব্লাস্টের ছত্রাকনাশকটা অর্ডার করো" contains a product
    //    word and an order word, and must not be mistaken for a search.
    final isOrder = _hasAny(lower, ['অর্ডার করো', 'অর্ডার করে', 'কিনব',
      'কিনতে', 'নিয়ে আসো', 'order', 'buy']);
    if (isOrder) {
      final category = _categoryIn(lower);
      if (category == null) {
        // Ordering something unnamed: ask which product, do not guess.
        return VoiceCommand(
          intent: VoiceIntent.orderProduct,
          transcript: text,
          confidence: 0.55,
          quantity: _quantityIn(lower),
        );
      }
      return VoiceCommand(
        intent: VoiceIntent.orderProduct,
        transcript: text,
        confidence: 0.92,
        category: category.$2,
        query: category.$1,
        quantity: _quantityIn(lower),
      );
    }

    // 2. Looking for a product, not buying it yet.
    final isSearch = _hasAny(lower, ['দেখাও', 'খুঁজে', 'কী আছে', 'show', 'find',
      'search']);
    final searchCategory = _categoryIn(lower);
    if (isSearch || searchCategory != null) {
      return VoiceCommand(
        intent: VoiceIntent.searchProduct,
        transcript: text,
        confidence: searchCategory == null ? 0.62 : 0.9,
        category: searchCategory?.$2,
        query: searchCategory?.$1,
      );
    }

    // 3. Weather, then screens.
    if (_hasAny(lower, ['আবহাওয়া', 'বৃষ্টি', 'weather', 'rain'])) {
      return VoiceCommand(
        intent: VoiceIntent.weather,
        transcript: text,
        confidence: 0.9,
        destination: VoiceDestination.weather,
      );
    }
    // 4. A question gets an answer, never an action — and questions are checked
    //    before screens, because "ধানে পাতা পোড়া রোগে কী করব?" contains "রোগ"
    //    and must not be read as "open the diagnosis screen". The answer here is
    //    deliberately generic: knowledge.md forbids inventing a pesticide dose,
    //    so the demo answer sends the farmer to a person rather than naming one.
    if (_hasAny(lower, ['কী কর', 'কি কর', 'কী হবে', 'কেন', 'কীভাবে', 'কত',
      'how', 'why', 'what should'])) {
      return VoiceCommand(
        intent: VoiceIntent.ask,
        transcript: text,
        confidence: 0.75,
        answer: _demoAnswer(lower),
      );
    }

    // 5. Screens. A keyword on its own ("বাজার", "আবহাওয়া") is heard but is not
    //    enough to act on — the sheet offers options instead of guessing where
    //    the farmer wanted to go.
    for (final (phrase, destination) in _destinations) {
      if (!lower.contains(phrase)) continue;
      final bare = lower
              .replaceAll(RegExp(r'[\s।?!,.]+$'), '')
              .trim() ==
          phrase;
      return VoiceCommand(
        intent: VoiceIntent.navigate,
        transcript: text,
        confidence: bare ? 0.55 : 0.88,
        destination: destination,
      );
    }

    return VoiceCommand.unknown(text);
  }

  String _demoAnswer(String question) =>
      'এটি ডেমো উত্তর: আক্রান্ত গাছ আলাদা করে রাখুন, পাতা পুড়ে ফেলুন এবং '
      'স্থানীয় উপ-সহকারী কৃষি কর্মকর্তাকে দেখান। সঠিক ওষুধ ও মাত্রা '
      'যাচাই করা জ্ঞানভাণ্ডার থেকে দেওয়া হবে, আমি নিজে বানিয়ে বলব না।';

  bool _hasAny(String haystack, List<String> needles) =>
      needles.any(haystack.contains);

  (String, String)? _categoryIn(String text) {
    for (final entry in _categories) {
      if (text.contains(entry.$1) || text.contains(entry.$1.toLowerCase())) {
        return entry;
      }
    }
    return null;
  }

  int _quantityIn(String text) {
    for (final entry in _numbers.entries) {
      if (text.contains(entry.key)) return entry.value;
    }
    final digits = RegExp(r'(\d+)').firstMatch(text);
    final parsed = int.tryParse(digits?.group(1) ?? '') ?? 1;
    return parsed.clamp(1, 20);
  }

  /// `POST /voice/ask`.
  ///
  /// A tiny knowledge base with a deliberate hole in it: "found" answers cite a
  /// source, and anything outside the base comes back as `found: false` with
  /// `offer_expert: true`. That is the behaviour the AI service has to keep, and
  /// the mock exists so the assistant's empty state is built now rather than
  /// after the model arrives.
  @override
  Future<VoiceAnswer> ask(String question) async {
    await _maybeFail(_config);
    final text = question.trim().toLowerCase();
    if (text.isEmpty) {
      return const VoiceAnswer(
        transcript: '',
        found: false,
        answerText: 'প্রশ্নটি শুনতে পারিনি। আবার বলুন বা লিখুন।',
      );
    }

    for (final entry in _knowledge) {
      if (entry.keywords.any(text.contains)) {
        return VoiceAnswer(
          transcript: question,
          found: true,
          answerText: entry.answerBn,
          sources: [entry.source],
        );
      }
    }

    return VoiceAnswer(
      transcript: question,
      found: false,
      answerText: 'এই প্রশ্নের উত্তর যাচাই করা জ্ঞানভাণ্ডারে নেই, তাই আমি আন্দাজে '
          'বলছি না। বিশেষজ্ঞকে পাঠালে কৃষিবিদ উত্তর দেবেন।',
      offerExpert: true,
    );
  }

  /// Keyword → answer, each with the document it came from and a source line
  /// the farmer can see. No dose is ever stated: `knowledge.md` forbids the app
  /// from producing pesticide quantities it cannot cite.
  static const List<_KbEntry> _knowledge = [
    _KbEntry(
      keywords: ['ব্লাস্ট', 'blast', 'বাদামি দাগ', 'brown spot'],
      answerBn: 'ধানের ব্লাস্টে আক্রান্ত গাছ দেখা গেলে প্রথমে জমির পানি নিষ্কাশনের '
          'ব্যবস্থা করুন এবং নাইট্রোজেন সারের শেষ কিস্তি কমান। কোন ওষুধ কী মাত্রায় '
          'দিতে হবে তা উপ-সহকারী কৃষি কর্মকর্তার সাথে মিলে ঠিক করুন।',
      source: VoiceSource(title: 'BRRI বুলেটিন — ধানের রোগ ব্যবস্থাপনা'),
    ),
    _KbEntry(
      keywords: ['নাবি ধসা', 'লেট ব্লাইট', 'late blight'],
      answerBn: 'আলুর নাবি ধসা ঠান্ডা আর কুয়াশাচ্ছন্ন আবহাওয়ায় দ্রুত ছড়ায়। '
          'আক্রান্ত গাছ তুলে ফেলুন, জমিতে পানি জমতে দেবেন না, এবং আক্রমণ শুরুতেই '
          'কৃষি কর্মকর্তার পরামর্শ নিন।',
      source: VoiceSource(title: 'DAE — আলুর রোগ ও প্রতিকার'),
    ),
    _KbEntry(
      keywords: ['সার', 'ইউরিয়া', 'fertilizer'],
      answerBn: 'সারের পরিমাণ মাটির পরীক্ষা আর ফসলের বয়সের উপর নির্ভর করে। '
          'আপনার জেলার জন্য সঠিক মাত্রা জানতে স্থানীয় কৃষি কর্মকর্তা বা মৃত্তিকা '
          'সম্পদ উন্নয়ন ইনস্টিটিউটের পরামর্শ নিন।',
      source: VoiceSource(title: 'SRDI — সার সুপারিশ'),
    ),
    _KbEntry(
      keywords: ['পোকা', 'মাজরা', 'pest', 'insect'],
      answerBn: 'পোকার আক্রমণ কমাতে সমন্বিত বালাই ব্যবস্থাপনা সবচেয়ে ভালো কাজ করে — '
          'ফেরোমন ফাঁদ, আলোর ফাঁদ আর আক্রান্ত পাতা সরিয়ে ফেলা। রাসায়নিক ব্যবহারের '
          'আগে কৃষি কর্মকর্তার পরামর্শ নিন।',
      source: VoiceSource(title: 'DAE — সমন্বিত বালাই ব্যবস্থাপনা'),
    ),
  ];
}

class _KbEntry {
  const _KbEntry({
    required this.keywords,
    required this.answerBn,
    required this.source,
  });

  final List<String> keywords;
  final String answerBn;
  final VoiceSource source;
}

/// Phase 1 crop advice (FR-13) and calendar (FR-15).
///
/// The ranking is a small rule table plus the district's live weather, not a
/// model: it exists so the screen, its reasons and the "weather included" note
/// are real before the recommender service exists. Two behaviours are
/// deliberate, because the AI service must keep them:
///
/// * every recommendation carries a reason the farmer can judge;
/// * heavy-rain risk *lowers* the crops that suffer in wet soil and says so,
///   rather than quietly returning a different order.
class MockCropRepository implements CropRepository {
  MockCropRepository({MockConfig? config})
      : _config = config ?? MockConfig(),
        _weather = MockWeatherRepository(config: config ?? MockConfig());

  final MockConfig _config;
  final MockWeatherRepository _weather;

  /// Recommendations asked for in this session. `API_SPEC` has no save
  /// endpoint, so this is what `GET /crops/recommendations` would return.
  final List<CropAdvice> _saved = [];

  @override
  Future<List<String>> soilTypes() async {
    await _lag();
    return kSoilTypes;
  }

  @override
  Future<List<String>> seasons() async {
    await _lag();
    return Seasons.all;
  }

  @override
  Future<List<String>> districts() async {
    await _lag();
    return kDistricts;
  }

  @override
  Future<List<CropAdvice>> savedRecommendations() async {
    await _lag();
    return List.unmodifiable(_saved.reversed);
  }

  @override
  Future<CropAdvice> recommend({
    required String district,
    required String soilType,
    required String season,
  }) async {
    // Latency is simulated once, and the weather call below carries the
    // injectable failure rate — doubling both made the screen feel broken.
    await _lag();

    final report = await _weather.report(district: district);
    final heavyRain = report.alerts.any((a) => a.type == 'heavy_rain');

    final scored = [
      for (final candidate in _candidates[season] ?? _candidates[Seasons.rabi]!)
        _score(candidate, soilType: soilType, heavyRain: heavyRain),
    ]..sort((a, b) => b.score.compareTo(a.score));

    final advice = CropAdvice(
      id: 'adv-${DateTime.now().microsecondsSinceEpoch}',
      weatherIncluded: true,
      results: [
        for (var i = 0; i < scored.take(3).length; i++)
          CropRecommendation(
            rank: i + 1,
            crop: scored[i].crop,
            reasonBn: scored[i].reason,
            score: scored[i].score,
          ),
      ],
      district: district,
      soilType: soilType,
      season: season,
      createdAt: DateTime.now(),
    );
    _saved.add(advice);
    return advice;
  }

  _ScoredCrop _score(
    _CropCandidate candidate, {
    required String soilType,
    required bool heavyRain,
  }) {
    var score = candidate.baseScore;
    final reasons = <String>[
      '${candidate.season} মৌসুমে ${candidate.cropBn} চাষের সময়',
    ];

    if (candidate.soils.contains(soilType)) {
      score += 0.08;
      reasons.add('$soilType এই ফসলের জন্য ভালো');
    } else {
      reasons.add('$soilType-এ ফলন কিছুটা কম হতে পারে');
    }

    if (heavyRain) {
      if (candidate.wantsWater) {
        score += 0.05;
        reasons.add('ভারী বৃষ্টির সম্ভাবনা থাকায় পানি-প্রিয় এই ফসলের জন্য অনুকূল');
      } else {
        score -= 0.12;
        reasons.add('ভারী বৃষ্টির পূর্বাভাসে জমিতে পানি জমার ঝুঁকি আছে');
      }
    }

    return _ScoredCrop(
      crop: candidate.crop,
      score: double.parse(score.clamp(0.05, 0.99).toStringAsFixed(2)),
      reason: '${reasons.join('। ')}।',
    );
  }

  static const Map<String, List<_CropCandidate>> _candidates = {
    Seasons.rabi: [
      _CropCandidate(
        crop: CropType.potato,
        cropBn: 'আলু',
        season: Seasons.rabi,
        baseScore: 0.78,
        soils: ['দোআঁশ মাটি', 'পলি মাটি', 'বেলে দোআঁশ'],
        wantsWater: false,
      ),
      _CropCandidate(
        crop: CropType.tomato,
        cropBn: 'টমেটো',
        season: Seasons.rabi,
        baseScore: 0.70,
        soils: ['দোআঁশ মাটি', 'পলি মাটি'],
        wantsWater: false,
      ),
      _CropCandidate(
        crop: CropType.rice,
        cropBn: 'বোরো ধান',
        season: Seasons.rabi,
        baseScore: 0.62,
        soils: ['এঁটেল মাটি', 'পলি মাটি'],
        wantsWater: true,
      ),
    ],
    Seasons.kharif1: [
      _CropCandidate(
        crop: CropType.rice,
        cropBn: 'আউশ ধান',
        season: Seasons.kharif1,
        baseScore: 0.80,
        soils: ['এঁটেল মাটি', 'দোআঁশ মাটি', 'পলি মাটি'],
        wantsWater: true,
      ),
      _CropCandidate(
        crop: CropType.tomato,
        cropBn: 'টমেটো',
        season: Seasons.kharif1,
        baseScore: 0.58,
        soils: ['বেলে দোআঁশ', 'দোআঁশ মাটি'],
        wantsWater: false,
      ),
      _CropCandidate(
        crop: CropType.potato,
        cropBn: 'আলু',
        season: Seasons.kharif1,
        baseScore: 0.45,
        soils: ['বেলে দোআঁশ'],
        wantsWater: false,
      ),
    ],
    Seasons.kharif2: [
      _CropCandidate(
        crop: CropType.rice,
        cropBn: 'আমন ধান',
        season: Seasons.kharif2,
        baseScore: 0.82,
        soils: ['এঁটেল মাটি', 'পলি মাটি', 'দোআঁশ মাটি'],
        wantsWater: true,
      ),
      _CropCandidate(
        crop: CropType.tomato,
        cropBn: 'টমেটো',
        season: Seasons.kharif2,
        baseScore: 0.52,
        soils: ['বেলে দোআঁশ', 'দোআঁশ মাটি'],
        wantsWater: false,
      ),
      _CropCandidate(
        crop: CropType.potato,
        cropBn: 'আলু',
        season: Seasons.kharif2,
        baseScore: 0.40,
        soils: ['বেলে দোআঁশ'],
        wantsWater: false,
      ),
    ],
  };

  @override
  Future<CropCalendar> calendar(CropType crop) async {
    await _maybeFail(_config);
    return CropCalendar.fromJson(_calendarSeed[crop.wire]!);
  }

  /// Windows by crop, in the `GET /calendar` wire shape. Rice has two seasons in
  /// the ground at once (aus and aman), which is why a crop can carry two
  /// planting windows.
  static const Map<String, Map<String, dynamic>> _calendarSeed = {
    'rice': {
      'crop': 'rice',
      'windows': [
        {
          'activity': 'planting',
          'start_month': 3,
          'end_month': 4,
          'note_bn': 'বোরো ধান কাটার পরপরই আউশের বীজতলা',
        },
        {'activity': 'harvest', 'start_month': 7, 'end_month': 8},
        {
          'activity': 'planting',
          'start_month': 6,
          'end_month': 7,
          'note_bn': 'আমন ধানের চারা রোপণ',
        },
        {'activity': 'harvest', 'start_month': 11, 'end_month': 12},
      ],
    },
    'potato': {
      'crop': 'potato',
      'windows': [
        {
          'activity': 'planting',
          'start_month': 11,
          'end_month': 12,
          'note_bn': 'রবি মৌসুমে আলুর বীজ বপন',
        },
        {
          'activity': 'harvest',
          'start_month': 2,
          'end_month': 3,
          'note_bn': 'নাবি ধসার ঝুঁকি এড়াতে সময়মতো তোলা জরুরি',
        },
      ],
    },
    'tomato': {
      'crop': 'tomato',
      'windows': [
        {'activity': 'planting', 'start_month': 9, 'end_month': 10},
        {'activity': 'harvest', 'start_month': 12, 'end_month': 1},
      ],
    },
  };
}

class _CropCandidate {
  const _CropCandidate({
    required this.crop,
    required this.cropBn,
    required this.season,
    required this.baseScore,
    required this.soils,
    required this.wantsWater,
  });

  final CropType crop;
  final String cropBn;
  final String season;
  final double baseScore;
  final List<String> soils;

  /// True for crops that want standing water, which heavy rain helps.
  final bool wantsWater;
}

class _ScoredCrop {
  const _ScoredCrop({
    required this.crop,
    required this.score,
    required this.reason,
  });

  final CropType crop;
  final double score;
  final String reason;
}
