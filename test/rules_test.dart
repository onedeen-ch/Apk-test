import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:battle_tap/main.dart';

void main() {
  test('Ranked configuration is fixed', () {
    expect(BattleRules.rankedSeconds, 30);
    expect(BattleRules.rankedButtonWidthRatio, 0.44);
  });
  test('Random hunt duration always within requested bounds', () {
    final random = Random(42);
    final values = [for (var i = 0; i < 1000; i++) BattleRules.randomDuration(random)];
    expect(values.every((s) => s >= 18 && s <= 60), isTrue);
  });
  test('Late taps subtract exactly two points', () {
    expect(BattleRules.huntScore(53, 4), 45);
    expect(BattleRules.huntScore(0, 1), -2);
  });
}
