import 'package:agrisense/data/mock/mock_seed.dart';
import 'package:agrisense/data/models/diagnosis.dart';
import 'package:agrisense/data/models/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// `Diagnosis.canShowDisease` is the last line of defence for the app's most
/// expensive rule: a wrong disease name costs a farmer the price of the wrong
/// pesticide plus the crop. The server is supposed to null the disease out below
/// 0.70, but this asserts the client refuses to display one even if a buggy or
/// compromised server sends `show_as_final: true` anyway.
void main() {
  Diagnosis fromWire(Map<String, dynamic> json) => Diagnosis.fromJson(json);

  final disease = kDiseaseSeed[0];

  test('a low score is never shown as a disease, even with show_as_final true', () {
    final d = fromWire({
      'id': 'x',
      'client_uuid': 'u',
      'status': 'completed',
      'confidence': 0.42,
      'confidence_level': 'low',
      'show_as_final': true,
      'disease': disease,
      'treatment_steps': kTreatmentSeed['dis-rice-blast'],
      'created_at': DateTime.now().toIso8601String(),
    });

    expect(d.canShowDisease, isFalse);
    expect(d.confidenceLevel.isShowable, isFalse);
  });

  test('a low score with no server flag is also hidden', () {
    final d = fromWire({
      'id': 'x',
      'client_uuid': 'u',
      'status': 'pending_review',
      'confidence': 0.62,
      'confidence_level': 'low',
      'show_as_final': false,
      'disease': null,
      'created_at': DateTime.now().toIso8601String(),
    });

    expect(d.canShowDisease, isFalse);
    expect(d.disease, isNull);
    expect(d.isPendingReview, isTrue);
  });

  test('an omitted confidence_level is derived from the score, not trusted', () {
    final d = fromWire({
      'id': 'x',
      'client_uuid': 'u',
      'status': 'completed',
      'confidence': 0.55,
      'disease': disease,
      'show_as_final': true,
      'created_at': DateTime.now().toIso8601String(),
    });

    expect(d.confidenceLevel, ConfidenceLevel.low);
    expect(d.canShowDisease, isFalse);
  });

  test('high confidence with the flag set is showable', () {
    final d = fromWire({
      'id': 'x',
      'client_uuid': 'u',
      'status': 'completed',
      'confidence': 0.91,
      'confidence_level': 'high',
      'show_as_final': true,
      'disease': disease,
      'created_at': DateTime.now().toIso8601String(),
    });

    expect(d.canShowDisease, isTrue);
    expect(d.disease!.nameBn, isNotEmpty);
  });

  test('a healthy result is distinguishable from a missing one', () {
    final healthy = fromWire({
      'id': 'x',
      'client_uuid': 'u',
      'status': 'completed',
      'confidence': 0.96,
      'confidence_level': 'high',
      'show_as_final': true,
      'disease': kDiseaseSeed[4],
      'created_at': DateTime.now().toIso8601String(),
    });

    expect(healthy.canShowDisease, isTrue);
    expect(healthy.isHealthy, isTrue);
  });

  test('every seeded diagnosis keeps the safety invariant', () {
    // Guards the seed itself: a demo row that showed a disease below 0.70 would
    // teach the wrong behaviour to whoever reviews the UI next.
    for (final json in diagnosisSeed(DateTime(2026, 6, 12).toIso8601String())) {
      final d = fromWire(json);
      final score = d.confidence;
      if (score < ConfidenceLevel.lowThreshold) {
        expect(
          d.canShowDisease,
          isFalse,
          reason: 'seeded diagnosis ${d.id} has $score but shows a disease',
        );
        expect(d.treatmentSteps, isNull);
        expect(d.top3, isEmpty);
      }
    }
  });

  test('treatment steps parse in order with their source attributed', () {
    final d = fromWire(diagnosisSeed(DateTime.now().toIso8601String())[0]);
    expect(d.treatmentSteps, isNotNull);
    expect(d.treatmentSteps!.first.order, 1);
    expect(d.treatmentSteps!.first.source, isNotNull);
    expect(d.treatmentSteps!.first.source, 'BRRI');
  });
}
