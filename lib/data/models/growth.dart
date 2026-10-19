import 'package:flutter/foundation.dart';

/// Models for the vendor CRM, the expert studio and the admin control room.
///
/// These screens are UI-first: the backend contract for them has not been
/// written yet, so nothing here parses JSON. When `API_SPEC.md` grows the
/// endpoints, the wire shape is added to the server-owned models instead of
/// being guessed here.

/// One day in a small trend chart.
@immutable
class TrendPoint {
  const TrendPoint({required this.day, required this.value});

  final DateTime day;
  final double value;
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

  /// `new | repeat | loyal | atRisk`. Kept as a wire-style string so the mock
  /// and a future server field cannot drift.
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

  int get repeatCustomers =>
      customers.where((c) => c.orders > 1).length;

  double get conversion =>
      storeVisits == 0 ? 0 : (orders30 / storeVisits) * 100;
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
}

/// A farmer's request for a person, not an article. `message`, `call` and
/// `video` are the three ways the expert can answer (calling itself is wired
/// when the backend lands).
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
