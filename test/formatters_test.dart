import 'package:agrisense/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Guards the "Bangla digits by default" rule. If `intl` ever stops giving the
/// `bn` locale Bengali digits, every price, percentage and date in the app would
/// silently start showing Latin numerals — this test is what catches that.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('bn', null);
    await initializeDateFormatting('en', null);
  });

  final bn = AppFormat('bn');
  final en = AppFormat('en');

  test('bn renders Bengali digits, en renders Latin', () {
    expect(bn.number(1250), '১,২৫০');
    expect(en.number(1250), '1,250');
    expect(bn.usesBanglaDigits, isTrue);
    expect(en.usesBanglaDigits, isFalse);
  });

  test('no Latin digit ever leaks into a bn-formatted string', () {
    final latin = RegExp(r'[0-9]');
    final samples = <String>[
      bn.number(0),
      bn.number(7),
      bn.number(123456),
      bn.number(2.5, decimals: 1),
      bn.percentFromFraction(0.91),
      bn.percentFromFraction(0.7, decimals: 1),
      bn.taka(900),
      bn.shortDate(DateTime(2026, 6, 12)),
      bn.longDate(DateTime(2026, 6, 12)),
      bn.monthName(6),
      bn.weekday(DateTime(2026, 6, 12)),
    ];
    for (final s in samples) {
      expect(latin.hasMatch(s), isFalse, reason: 'Latin digit found in "$s"');
    }
  });

  test('confidence fraction becomes a percentage, not a raw 0-1 number', () {
    // Confidence is stored 0.0-1.0 everywhere; showing "0.91%" would be a
    // silent 100x error, so pin the behaviour.
    expect(bn.percentFromFraction(0.91), '৯১%');
    expect(bn.percentFromFraction(0.65), '৬৫%');
    expect(en.percentFromFraction(0.91), '91%');
    expect(bn.percentFromFraction(0.855, decimals: 1), '৮৫.৫%');
  });

  test('money is integer taka with the taka sign', () {
    expect(bn.taka(900), '৯০০ ৳');
    expect(bn.taka(12500), '১২,৫০০ ৳');
    expect(en.taka(900), '900 ৳');
  });

  test('dates are localised, not ISO', () {
    final d = DateTime(2026, 6, 12);
    expect(bn.shortDate(d), contains('১২'));
    expect(en.shortDate(d), contains('12'));
    expect(bn.shortDate(d), isNot(contains('2026-06-12')));
  });
}
