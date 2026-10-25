import 'package:agrisense/data/mock/mock_repositories.dart';
import 'package:agrisense/data/models/crop.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// FR-13 and FR-15, at the level the screen depends on: three ranked crops, each
/// with a reason a farmer can judge, and a calendar whose windows actually cover
/// the months they claim.
void main() {
  late MockCropRepository crops;

  setUp(() => crops = MockCropRepository(config: MockConfig()));

  test('the season suggestion follows the calendar', () {
    expect(Seasons.forMonth(1), Seasons.rabi);
    expect(Seasons.forMonth(3), Seasons.rabi);
    expect(Seasons.forMonth(5), Seasons.kharif1);
    expect(Seasons.forMonth(8), Seasons.kharif2);
    expect(Seasons.forMonth(11), Seasons.rabi);
  });

  test('every recommendation has a rank, a reason and a score', () async {
    final advice = await crops.recommend(
      district: 'ঢাকা',
      soilType: 'দোআঁশ মাটি',
      season: Seasons.rabi,
    );

    expect(advice.results, hasLength(3));
    expect(advice.results.map((r) => r.rank), [1, 2, 3]);
    for (final result in advice.results) {
      expect(result.reasonBn, isNotEmpty,
          reason: 'a ranked crop without a reason is a guess');
      expect(result.score, inInclusiveRange(0.05, 0.99));
    }
    // The mock does consult the district's weather, and says so.
    expect(advice.weatherIncluded, isTrue);
  });

  test('a good soil match is said out loud', () async {
    final advice = await crops.recommend(
      district: 'ঢাকা',
      soilType: 'দোআঁশ মাটি',
      season: Seasons.rabi,
    );
    expect(advice.results.first.reasonBn, contains('দোআঁশ মাটি'));
  });

  test('the district weather changes the ranking and is named in the reason',
      () async {
    // Dhaka's seeded weather carries a heavy-rain alert. On heavy clay that
    // makes rice (which wants standing water) the top pick, and the reason has
    // to admit why: 0.62 base + 0.08 soil match + 0.05 rain.
    final advice = await crops.recommend(
      district: 'ঢাকা',
      soilType: 'এঁটেল মাটি',
      season: Seasons.rabi,
    );

    expect(advice.results.first.crop, CropType.rice);
    expect(advice.results.first.score, closeTo(0.75, 0.001));
    expect(
      advice.results.map((r) => r.reasonBn).join(' '),
      contains('বৃষ্টি'),
    );
  });

  test('asking twice keeps both in the saved list, newest first', () async {
    await crops.recommend(
      district: 'ঢাকা',
      soilType: 'দোআঁশ মাটি',
      season: Seasons.rabi,
    );
    final second = await crops.recommend(
      district: 'রংপুর',
      soilType: 'এঁটেল মাটি',
      season: Seasons.kharif2,
    );

    final saved = await crops.savedRecommendations();
    expect(saved, hasLength(2));
    expect(saved.first.id, second.id);
  });

  test('soil types and seasons come from the reference lists', () async {
    expect(await crops.soilTypes(), contains('দোআঁশ মাটি'));
    expect(await crops.seasons(), Seasons.all);
    expect(await crops.districts(), contains('ঢাকা'));
  });

  test('rice carries two planting windows and harvests twice', () async {
    final calendar = await crops.calendar(CropType.rice);

    expect(calendar.windows, hasLength(4));
    expect(
      calendar.windows.where((w) => w.activity == CropActivity.planting),
      hasLength(2),
    );
    expect(calendar.hasActivityIn(7), isTrue);
    expect(calendar.hasActivityIn(1), isFalse);
  });

  test('a window that wraps the new year still covers January', () {
    const window = CropWindow(
      activity: CropActivity.harvest,
      startMonth: 12,
      endMonth: 1,
    );
    expect(window.covers(12), isTrue);
    expect(window.covers(1), isTrue);
    expect(window.covers(6), isFalse);
  });
}
