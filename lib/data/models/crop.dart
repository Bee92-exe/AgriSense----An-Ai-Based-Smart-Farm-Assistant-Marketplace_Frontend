import 'package:flutter/foundation.dart';

import 'enums.dart';

/// The three growing seasons Bangladesh plans by.
///
/// A season is what `/meta/seasons` returns: a display string, like districts
/// are. The auto-suggestion below is a calendar fact, not a server fact, which
/// is why it lives here rather than behind an endpoint.
abstract final class Seasons {
  const Seasons._();

  static const rabi = 'রবি';
  static const kharif1 = 'খরিফ-১';
  static const kharif2 = 'খরিফ-২';

  static const all = [rabi, kharif1, kharif2];

  /// Rabi planting runs November to March, kharif-1 April to June, kharif-2
  /// July to October.
  static String forMonth(int month) => switch (month) {
        11 || 12 || 1 || 2 || 3 => rabi,
        4 || 5 || 6 => kharif1,
        _ => kharif2,
      };
}

/// One ranked crop from `POST /crops/recommend`.
@immutable
class CropRecommendation {
  const CropRecommendation({
    required this.rank,
    required this.crop,
    required this.reasonBn,
    required this.score,
  });

  /// 1, 2, 3 — the order the cards are shown in, not a position in a list.
  final int rank;
  final CropType crop;

  /// Why this crop, in Bangla and in the farmer's terms. The reason is the
  /// whole feature: a ranked name without a reason is a guess.
  final String reasonBn;

  /// 0.0-1.0.
  final double score;

  factory CropRecommendation.fromJson(Map<String, dynamic> json) =>
      CropRecommendation(
        rank: (json['rank'] as num?)?.toInt() ?? 1,
        crop: CropType.fromWire(json['crop'] as String?) ?? CropType.rice,
        reasonBn: json['reason_bn'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0,
      );
}

/// A whole recommendation answer: what the farmer asked with, and what came
/// back.
@immutable
class CropAdvice {
  const CropAdvice({
    required this.id,
    required this.weatherIncluded,
    required this.results,
    required this.district,
    required this.soilType,
    required this.season,
    required this.createdAt,
  });

  final String id;

  /// True when the ranking took the district's live weather into account. Shown
  /// to the farmer either way, because "we ignored the forecast" is a real
  /// difference in how much to trust the answer.
  final bool weatherIncluded;

  final List<CropRecommendation> results;
  final String district;
  final String soilType;
  final String season;
  final DateTime createdAt;

  factory CropAdvice.fromJson(Map<String, dynamic> json) => CropAdvice(
        id: json['id'] as String? ?? '',
        weatherIncluded: json['weather_included'] as bool? ?? false,
        results: ((json['results'] as List<dynamic>?) ?? const [])
            .map((e) => CropRecommendation.fromJson(e as Map<String, dynamic>))
            .toList(),
        district: json['district'] as String? ?? '',
        soilType: json['soil_type'] as String? ?? '',
        season: json['season'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now(),
      );
}

/// Planting or harvest — the two things a calendar window can mean.
enum CropActivity {
  planting('planting'),
  harvest('harvest');

  const CropActivity(this.wire);

  final String wire;

  static CropActivity fromWire(String? value) => CropActivity.values.firstWhere(
        (a) => a.wire == value,
        orElse: () => CropActivity.planting,
      );
}

/// One window from `GET /calendar?crop=rice`.
@immutable
class CropWindow {
  const CropWindow({
    required this.activity,
    required this.startMonth,
    required this.endMonth,
    this.noteBn,
  });

  final CropActivity activity;

  /// 1-12, inclusive.
  final int startMonth;
  final int endMonth;
  final String? noteBn;

  /// Months are inclusive on both ends, and a window may wrap the new year.
  bool covers(int month) {
    if (startMonth <= endMonth) {
      return month >= startMonth && month <= endMonth;
    }
    return month >= startMonth || month <= endMonth;
  }

  factory CropWindow.fromJson(Map<String, dynamic> json) => CropWindow(
        activity: CropActivity.fromWire(json['activity'] as String?),
        startMonth: (json['start_month'] as num?)?.toInt() ?? 1,
        endMonth: (json['end_month'] as num?)?.toInt() ?? 1,
        noteBn: json['note_bn'] as String?,
      );
}

@immutable
class CropCalendar {
  const CropCalendar({required this.crop, required this.windows});

  final CropType crop;
  final List<CropWindow> windows;

  bool hasActivityIn(int month) =>
      windows.any((w) => w.covers(month));

  factory CropCalendar.fromJson(Map<String, dynamic> json) => CropCalendar(
        crop: CropType.fromWire(json['crop'] as String?) ?? CropType.rice,
        windows: ((json['windows'] as List<dynamic>?) ?? const [])
            .map((e) => CropWindow.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

