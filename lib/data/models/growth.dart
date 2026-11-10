import 'package:flutter/foundation.dart';

/// Models for the vendor CRM, the expert studio and the admin control room.
///
/// Every class here that the server returns carries a `fromJson`. The wire keys
/// are snake_case because the Express serializers emit snake_case, matching the
/// rest of the API.

/// One day in a small trend chart.
@immutable
class TrendPoint {
  const TrendPoint({required this.day, required this.value});

  final DateTime day;
  final double value;

  factory TrendPoint.fromJson(Map<String, dynamic> json) => TrendPoint(
        day: DateTime.tryParse(json['day'] as String? ?? '') ?? DateTime.now(),
        value: (json['value'] as num?)?.toDouble() ?? 0,
      );
}

/// A buyer the vendor has sold to at least once, with the notes the shop keeps
/// about them (the CRM half of the vendor panel).
@immutable
class VendorCustomer {
  const VendorCustomer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.district,
    required this.orders,
    required this.totalSpent,
    required this.lastOrderAt,
    required this.segment,
    this.note,
    this.followUp = false,
  });

  final String id;
  final String name;
  final String mobile;
  final String district;
  final int orders;
  final int totalSpent;
  final DateTime lastOrderAt;

  /// `new | repeat | loyal | atRisk`, derived by the server from order history.
  final String segment;

  final String? note;
  final bool followUp;

  VendorCustomer copyWith({String? note, bool? followUp}) => VendorCustomer(
        id: id,
        name: name,
        mobile: mobile,
        district: district,
        orders: orders,
        totalSpent: totalSpent,
        lastOrderAt: lastOrderAt,
        segment: segment,
        note: note ?? this.note,
        followUp: followUp ?? this.followUp,
      );

  factory VendorCustomer.fromJson(Map<String, dynamic> json) => VendorCustomer(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        mobile: json['mobile'] as String? ?? '',
        district: json['district'] as String? ?? '',
        orders: (json['orders'] as num?)?.toInt() ?? 0,
        totalSpent: (json['total_spent'] as num?)?.toInt() ?? 0,
        lastOrderAt:
            DateTime.tryParse(json['last_order_at'] as String? ?? '') ??
                DateTime.now(),
        segment: json['segment'] as String? ?? 'new',
        note: json['note'] as String?,
        followUp: json['follow_up'] as bool? ?? false,
      );
}

/// One line in the vendor's payout history.
@immutable
class VendorPayout {
  const VendorPayout({
    required this.id,
    required this.amount,
    required this.at,
    required this.status,
  });

  final String id;
  final int amount;
  final DateTime at;
  final String status;

  factory VendorPayout.fromJson(Map<String, dynamic> json) => VendorPayout(
        id: json['id'] as String? ?? '',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
        status: json['status'] as String? ?? 'pending',
      );
}

/// The vendor's money view: what sold, what it earned, what the platform keeps
/// and who bought it.
@immutable
class VendorBusiness {
  const VendorBusiness({
    required this.week,
    required this.revenue30,
    required this.profit30,
    required this.commission30,
    required this.pendingPayout,
    required this.storeVisits,
    required this.orders30,
    required this.payouts,
    required this.topProducts,
    required this.customers,
    this.commissionPercent = 0,
  });

  final List<TrendPoint> week;
  final int revenue30;
  final int profit30;
  final int commission30;
  final int pendingPayout;
  final int storeVisits;
  final int orders30;
  final List<VendorPayout> payouts;
  final List<({String name, int units, int revenue})> topProducts;
  final List<VendorCustomer> customers;

  /// The rate the server actually applied, so the screen can say "10%" rather
  /// than hardcoding a number that could drift from configuration.
  final int commissionPercent;

  int get repeatCustomers => customers.where((c) => c.orders > 1).length;

  double get conversion =>
      storeVisits == 0 ? 0 : (orders30 / storeVisits) * 100;

  factory VendorBusiness.fromJson(Map<String, dynamic> json) => VendorBusiness(
        week: ((json['week'] as List<dynamic>?) ?? const [])
            .map((e) => TrendPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        revenue30: (json['revenue30'] as num?)?.toInt() ?? 0,
        profit30: (json['profit30'] as num?)?.toInt() ?? 0,
        commission30: (json['commission30'] as num?)?.toInt() ?? 0,
        commissionPercent: (json['commission_percent'] as num?)?.toInt() ?? 0,
        pendingPayout: (json['pending_payout'] as num?)?.toInt() ?? 0,
        storeVisits: (json['store_visits'] as num?)?.toInt() ?? 0,
        orders30: (json['orders30'] as num?)?.toInt() ?? 0,
        payouts: ((json['payouts'] as List<dynamic>?) ?? const [])
            .map((e) => VendorPayout.fromJson(e as Map<String, dynamic>))
            .toList(),
        topProducts: ((json['top_products'] as List<dynamic>?) ?? const [])
            .map((e) {
              final map = e as Map<String, dynamic>;
              return (
                name: map['name'] as String? ?? '',
                units: (map['units'] as num?)?.toInt() ?? 0,
                revenue: (map['revenue'] as num?)?.toInt() ?? 0,
              );
            })
            .toList(),
        customers: ((json['customers'] as List<dynamic>?) ?? const [])
            .map((e) => VendorCustomer.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// One comment under an expert article.
@immutable
class ArticleComment {
  const ArticleComment({
    required this.id,
    required this.authorName,
    required this.body,
    required this.at,
    this.isExpert = false,
    this.likes = 0,
  });

  final String id;
  final String authorName;
  final String body;
  final DateTime at;
  final bool isExpert;
  final int likes;

  factory ArticleComment.fromJson(Map<String, dynamic> json) => ArticleComment(
        id: json['id'] as String? ?? '',
        authorName: json['author_name'] as String? ?? '',
        body: json['body'] as String? ?? '',
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
        isExpert: json['is_expert'] as bool? ?? false,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
      );
}

/// A published expert article — the social half of the expert panel.
@immutable
class ExpertArticle {
  const ExpertArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.authorName,
    required this.authorTitle,
    required this.crop,
    required this.publishedAt,
    required this.likes,
    required this.views,
    required this.rating,
    required this.ratingCount,
    required this.comments,
    this.coverTone = 0,
    this.liked = false,
    this.saved = false,
    this.mine = false,
  });

  final String id;
  final String title;
  final String summary;
  final String body;
  final String authorName;
  final String authorTitle;
  final String crop;
  final DateTime publishedAt;
  final int likes;
  final int views;
  final double rating;
  final int ratingCount;
  final List<ArticleComment> comments;

  /// Index into the app's tint list; the cover is painted, not downloaded, so
  /// the feed looks the same with no network.
  final int coverTone;

  final bool liked;
  final bool saved;
  final bool mine;

  ExpertArticle copyWith({
    int? likes,
    bool? liked,
    bool? saved,
    double? rating,
    int? ratingCount,
    List<ArticleComment>? comments,
  }) =>
      ExpertArticle(
        id: id,
        title: title,
        summary: summary,
        body: body,
        authorName: authorName,
        authorTitle: authorTitle,
        crop: crop,
        publishedAt: publishedAt,
        likes: likes ?? this.likes,
        views: views,
        rating: rating ?? this.rating,
        ratingCount: ratingCount ?? this.ratingCount,
        comments: comments ?? this.comments,
        coverTone: coverTone,
        liked: liked ?? this.liked,
        saved: saved ?? this.saved,
        mine: mine,
      );

  factory ExpertArticle.fromJson(Map<String, dynamic> json) => ExpertArticle(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        body: json['body'] as String? ?? '',
        authorName: json['author_name'] as String? ?? '',
        authorTitle: json['author_title'] as String? ?? '',
        crop: json['crop'] as String? ?? '',
        publishedAt:
            DateTime.tryParse(json['published_at'] as String? ?? '') ??
                DateTime.now(),
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        views: (json['views'] as num?)?.toInt() ?? 0,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        ratingCount: (json['rating_count'] as num?)?.toInt() ?? 0,
        comments: ((json['comments'] as List<dynamic>?) ?? const [])
            .map((e) => ArticleComment.fromJson(e as Map<String, dynamic>))
            .toList(),
        coverTone: (json['cover_tone'] as num?)?.toInt() ?? 0,
        liked: json['liked'] as bool? ?? false,
        saved: json['saved'] as bool? ?? false,
        mine: json['mine'] as bool? ?? false,
      );
}

/// A farmer's request for a person, not an article. `message`, `call` and
/// `video` are the three ways the expert can answer.
@immutable
class ExpertQuestion {
  const ExpertQuestion({
    required this.id,
    required this.farmerName,
    required this.farmerDistrict,
    required this.crop,
    required this.question,
    required this.mode,
    required this.createdAt,
    this.urgent = false,
    this.answered = false,
    this.reply,
  });

  final String id;
  final String farmerName;
  final String farmerDistrict;
  final String crop;
  final String question;
  final String mode;
  final DateTime createdAt;
  final bool urgent;
  final bool answered;
  final String? reply;

  ExpertQuestion copyWith({bool? answered, String? reply}) => ExpertQuestion(
        id: id,
        farmerName: farmerName,
        farmerDistrict: farmerDistrict,
        crop: crop,
        question: question,
        mode: mode,
        createdAt: createdAt,
        urgent: urgent,
        answered: answered ?? this.answered,
        reply: reply ?? this.reply,
      );

  factory ExpertQuestion.fromJson(Map<String, dynamic> json) => ExpertQuestion(
        id: json['id'] as String? ?? '',
        farmerName: json['farmer_name'] as String? ?? '',
        farmerDistrict: json['farmer_district'] as String? ?? '',
        crop: json['crop'] as String? ?? '',
        question: json['question'] as String? ?? '',
        mode: json['mode'] as String? ?? 'message',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
        urgent: json['urgent'] as bool? ?? false,
        answered: json['answered'] as bool? ?? false,
        reply: json['reply'] as String?,
      );
}

/// A consultation subscription the expert sells.
@immutable
class ConsultationPlan {
  const ConsultationPlan({
    required this.id,
    required this.title,
    required this.period,
    required this.price,
    required this.subscribers,
    required this.perks,
    this.active = true,
  });

  final String id;
  final String title;
  final String period;
  final int price;
  final int subscribers;
  final List<String> perks;
  final bool active;

  ConsultationPlan copyWith({bool? active, int? price}) => ConsultationPlan(
        id: id,
        title: title,
        period: period,
        price: price ?? this.price,
        subscribers: subscribers,
        perks: perks,
        active: active ?? this.active,
      );

  factory ConsultationPlan.fromJson(Map<String, dynamic> json) =>
      ConsultationPlan(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        period: json['period'] as String? ?? 'monthly',
        price: (json['price'] as num?)?.toInt() ?? 0,
        subscribers: (json['subscribers'] as num?)?.toInt() ?? 0,
        perks: ((json['perks'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        active: json['active'] as bool? ?? true,
      );
}

/// A booked call or visit.
@immutable
class ConsultationBooking {
  const ConsultationBooking({
    required this.id,
    required this.farmerName,
    required this.topic,
    required this.mode,
    required this.at,
    required this.minutes,
    required this.status,
  });

  final String id;
  final String farmerName;
  final String topic;
  final String mode;
  final DateTime at;
  final int minutes;

  /// `upcoming | done | cancelled`
  final String status;

  factory ConsultationBooking.fromJson(Map<String, dynamic> json) =>
      ConsultationBooking(
        id: json['id'] as String? ?? '',
        farmerName: json['farmer_name'] as String? ?? '',
        topic: json['topic'] as String? ?? '',
        mode: json['mode'] as String? ?? 'call',
        at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
        minutes: (json['minutes'] as num?)?.toInt() ?? 30,
        status: json['status'] as String? ?? 'upcoming',
      );
}

/// Another expert the signed-in expert can connect with.
@immutable
class ExpertPeer {
  const ExpertPeer({
    required this.id,
    required this.name,
    required this.specialization,
    required this.district,
    required this.rating,
    required this.followers,
    this.connected = false,
  });

  final String id;
  final String name;
  final String specialization;
  final String district;
  final double rating;
  final int followers;
  final bool connected;

  ExpertPeer copyWith({bool? connected}) => ExpertPeer(
        id: id,
        name: name,
        specialization: specialization,
        district: district,
        rating: rating,
        followers: followers,
        connected: connected ?? this.connected,
      );

  factory ExpertPeer.fromJson(Map<String, dynamic> json) => ExpertPeer(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        specialization: json['specialization'] as String? ?? '',
        district: json['district'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        followers: (json['followers'] as num?)?.toInt() ?? 0,
        connected: json['connected'] as bool? ?? false,
      );
}

/// Everything the expert's home and clients tabs need.
@immutable
class ExpertDesk {
  const ExpertDesk({
    required this.articles,
    required this.questions,
    required this.plans,
    required this.bookings,
    required this.peers,
    required this.rating,
    required this.followers,
    required this.subscribers,
    required this.earnings,
    required this.responseMinutes,
  });

  final List<ExpertArticle> articles;
  final List<ExpertQuestion> questions;
  final List<ConsultationPlan> plans;
  final List<ConsultationBooking> bookings;
  final List<ExpertPeer> peers;
  final double rating;
  final int followers;
  final int subscribers;
  final int earnings;
  final int responseMinutes;

  List<ExpertQuestion> get openQuestions =>
      questions.where((q) => !q.answered).toList(growable: false);

  List<ConsultationBooking> get upcoming =>
      bookings.where((b) => b.status == 'upcoming').toList(growable: false);

  factory ExpertDesk.fromJson(Map<String, dynamic> json) => ExpertDesk(
        articles: ((json['articles'] as List<dynamic>?) ?? const [])
            .map((e) => ExpertArticle.fromJson(e as Map<String, dynamic>))
            .toList(),
        questions: ((json['questions'] as List<dynamic>?) ?? const [])
            .map((e) => ExpertQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
        plans: ((json['plans'] as List<dynamic>?) ?? const [])
            .map((e) => ConsultationPlan.fromJson(e as Map<String, dynamic>))
            .toList(),
        bookings: ((json['bookings'] as List<dynamic>?) ?? const [])
            .map((e) => ConsultationBooking.fromJson(e as Map<String, dynamic>))
            .toList(),
        peers: ((json['peers'] as List<dynamic>?) ?? const [])
            .map((e) => ExpertPeer.fromJson(e as Map<String, dynamic>))
            .toList(),
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        followers: (json['followers'] as num?)?.toInt() ?? 0,
        subscribers: (json['subscribers'] as num?)?.toInt() ?? 0,
        earnings: (json['earnings'] as num?)?.toInt() ?? 0,
        responseMinutes: (json['response_minutes'] as num?)?.toInt() ?? 0,
      );
}

/// One point on the admin's platform-health chart.
@immutable
class AdminOverview {
  const AdminOverview({
    required this.gmv30,
    required this.commission30,
    required this.activeUsers,
    required this.newUsers7,
    required this.orders30,
    required this.pendingApprovals,
    required this.openIssues,
    required this.vendors,
    required this.week,
  });

  final int gmv30;
  final int commission30;
  final int activeUsers;
  final int newUsers7;
  final int orders30;
  final int pendingApprovals;
  final int openIssues;
  final int vendors;
  final List<TrendPoint> week;
}

/// A product as the admin sees it — every vendor's listing, including ones
/// taken down from the shop.
@immutable
class AdminProduct {
  const AdminProduct({
    required this.id,
    required this.name,
    required this.shopName,
    required this.category,
    required this.price,
    required this.stock,
    this.hidden = false,
  });

  final String id;
  final String name;
  final String shopName;
  final String category;
  final int price;
  final int stock;
  final bool hidden;

  AdminProduct copyWith({bool? hidden}) => AdminProduct(
        id: id,
        name: name,
        shopName: shopName,
        category: category,
        price: price,
        stock: stock,
        hidden: hidden ?? this.hidden,
      );
}

/// A published item (Krishi Barta or an expert article) as the admin's content
/// moderation list sees it.
@immutable
class AdminContent {
  const AdminContent({
    required this.id,
    required this.title,
    required this.author,
    required this.kind,
    required this.status,
    required this.publishedAt,
    this.hidden = false,
  });

  final String id;
  final String title;
  final String author;

  /// `news | article`
  final String kind;
  final String status;
  final DateTime publishedAt;
  final bool hidden;

  AdminContent copyWith({bool? hidden}) => AdminContent(
        id: id,
        title: title,
        author: author,
        kind: kind,
        status: status,
        publishedAt: publishedAt,
        hidden: hidden ?? this.hidden,
      );
}

/// Platform switches the admin owns.
@immutable
class AdminSettings {
  const AdminSettings({
    required this.commissionPercent,
    required this.autoApproveFarmers,
    required this.maintenance,
    required this.supportPhone,
    required this.broadcastBanner,
  });

  final int commissionPercent;
  final bool autoApproveFarmers;
  final bool maintenance;
  final String supportPhone;
  final String broadcastBanner;

  AdminSettings copyWith({
    int? commissionPercent,
    bool? autoApproveFarmers,
    bool? maintenance,
    String? supportPhone,
    String? broadcastBanner,
  }) =>
      AdminSettings(
        commissionPercent: commissionPercent ?? this.commissionPercent,
        autoApproveFarmers:
            autoApproveFarmers ?? this.autoApproveFarmers,
        maintenance: maintenance ?? this.maintenance,
        supportPhone: supportPhone ?? this.supportPhone,
        broadcastBanner: broadcastBanner ?? this.broadcastBanner,
      );
}
