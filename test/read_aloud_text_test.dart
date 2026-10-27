import 'package:agrisense/data/models/diagnosis.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:agrisense/data/models/news_item.dart';
import 'package:agrisense/features/diagnosis/result_screen.dart';
import 'package:agrisense/features/news/news_detail_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// What a farmer hears is part of the interface, so it gets asserted rather than
/// left to whoever last edited the screen.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('bn', null);
    await initializeDateFormatting('en', null);
  });

  test('treatment steps are read in order, numbered in Bangla digits', () {
    const steps = [
      TreatmentStep(order: 1, textBn: 'আক্রান্ত পাতা তুলে ফেলুন'),
      TreatmentStep(order: 2, textBn: 'ডোডিন ব্যবহার করুন'),
    ];

    expect(
      speechForSteps(steps, 'bn'),
      '১. আক্রান্ত পাতা তুলে ফেলুন. ২. ডোডিন ব্যবহার করুন',
    );
  });

  test('news is read as title, summary, then the advised action', () {
    final item = NewsItem(
      id: 'news-1',
      titleBn: 'ধানে ব্লাস্ট',
      titleEn: 'Rice blast',
      summaryBn: 'বাদামি দাগ দেখা দিচ্ছে।',
      summaryEn: 'Brown spots are appearing.',
      advisedActionBn: 'রোগ প্রতিরোধী জাতের বীজ ব্যবহার করুন।',
      category: NewsCategory.disease,
      crop: CropType.rice,
      severity: Severity.medium,
      publishedAt: DateTime(2026, 10, 17),
      source: const NewsSource(name: 'BRRI'),
    );

    final bn = speechForNews(item, 'bn');
    expect(bn.indexOf('ধানে ব্লাস্ট'), lessThan(bn.indexOf('বাদামি দাগ')));
    expect(bn, contains('রোগ প্রতিরোধী জাতের বীজ'));

    // Nothing in English is invented for the Bangla-only source fields.
    final en = speechForNews(item, 'en');
    expect(en, contains('Rice blast'));
    expect(en, isNot(contains('রোগ প্রতিরোধী')));
  });
}
