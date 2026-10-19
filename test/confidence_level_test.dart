import 'package:agrisense/data/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// The confidence bands are a safety rule, not a display preference: below 0.70
/// the app must never present a disease as final, and 0.70-0.85 must carry a
/// caution note. These are the exact boundaries from the PRD and
/// `frontend/docs/DESIGN_SYSTEM.md`, pinned so a later "tidy-up" of the
/// comparison operators cannot quietly loosen them.
void main() {
  group('ConfidenceLevel.fromScore', () {
    test('0.85 and above is high', () {
      expect(ConfidenceLevel.fromScore(1.0), ConfidenceLevel.high);
      expect(ConfidenceLevel.fromScore(0.85), ConfidenceLevel.high);
      expect(ConfidenceLevel.fromScore(0.851), ConfidenceLevel.high);
    });

    test('0.70 up to but not including 0.85 is medium', () {
      expect(ConfidenceLevel.fromScore(0.70), ConfidenceLevel.medium);
      expect(ConfidenceLevel.fromScore(0.849), ConfidenceLevel.medium);
      expect(ConfidenceLevel.fromScore(0.75), ConfidenceLevel.medium);
    });

    test('below 0.70 is low', () {
      expect(ConfidenceLevel.fromScore(0.699), ConfidenceLevel.low);
      expect(ConfidenceLevel.fromScore(0.0), ConfidenceLevel.low);
    });

    test('the boundary values themselves are inclusive at the bottom', () {
      // 0.85 belongs to high, not medium; 0.70 belongs to medium, not low.
      expect(ConfidenceLevel.fromScore(0.85), isNot(ConfidenceLevel.medium));
      expect(ConfidenceLevel.fromScore(0.70), isNot(ConfidenceLevel.low));
    });
  });

  group('Safety predicates', () {
    test('only high and medium may be shown to a farmer', () {
      expect(ConfidenceLevel.high.isShowable, isTrue);
      expect(ConfidenceLevel.medium.isShowable, isTrue);
      expect(ConfidenceLevel.low.isShowable, isFalse);
    });

    test('only medium needs the caution line', () {
      expect(ConfidenceLevel.medium.needsCaution, isTrue);
      expect(ConfidenceLevel.high.needsCaution, isFalse);
      expect(ConfidenceLevel.low.needsCaution, isFalse);
    });

    test('a low score is never "showable" even at the top of its range', () {
      for (var score = 0.0; score < ConfidenceLevel.lowThreshold; score += 0.01) {
        expect(
          ConfidenceLevel.fromScore(score).isShowable,
          isFalse,
          reason: 'score $score must not be showable',
        );
      }
    });
  });

  group('Wire parsing', () {
    test('server values round-trip', () {
      expect(ConfidenceLevel.fromWire('high'), ConfidenceLevel.high);
      expect(ConfidenceLevel.fromWire('medium'), ConfidenceLevel.medium);
      expect(ConfidenceLevel.fromWire('low'), ConfidenceLevel.low);
    });

    test('an unknown or missing value falls back to the safest band', () {
      // Falling back to `high` on an unparseable value would be the dangerous
      // direction, so the default must be `low`.
      expect(ConfidenceLevel.fromWire(null), ConfidenceLevel.low);
      expect(ConfidenceLevel.fromWire('HIGH'), ConfidenceLevel.low);
    });
  });

  group('Severity', () {
    test('only high and urgent trigger a push', () {
      expect(Severity.urgent.needsPush, isTrue);
      expect(Severity.high.needsPush, isTrue);
      expect(Severity.medium.needsPush, isFalse);
      expect(Severity.low.needsPush, isFalse);
    });

    test('every severity carries its own icon, so colour is never the only cue', () {
      final icons = Severity.values.map((s) => s.icon).toSet();
      expect(icons.length, Severity.values.length);
    });
  });

  group('OrderStatus', () {
    test('confirmed is folded into pending for the farmer (decision A4)', () {
      expect(OrderStatus.confirmed.farmerVisible, OrderStatus.pending);
      expect(OrderStatus.shipped.farmerVisible, OrderStatus.shipped);
    });

    test('terminal states are recognised', () {
      expect(OrderStatus.delivered.isTerminal, isTrue);
      expect(OrderStatus.rejected.isTerminal, isTrue);
      expect(OrderStatus.cancelled.isTerminal, isTrue);
      expect(OrderStatus.pending.isTerminal, isFalse);
      expect(OrderStatus.shipped.isTerminal, isFalse);
    });
  });
}
