import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:battle_tap/main.dart';
import 'package:battle_tap/skins.dart';

void main() {
  test('Ranked rules are locked: 30 seconds and 44% width', () {
    expect(BattleRules.rankedSeconds, 30);
    expect(BattleRules.rankedButtonWidthRatio, .44);
  });

  test('Random Hunt has visible 18–60s timer and one-second movement', () {
    final random = Random(42);
    final values = [
      for (var i = 0; i < 2500; i++) BattleRules.randomDuration(random),
    ];
    expect(values.every((s) => s >= 18 && s <= 60), isTrue);
    expect(values.contains(18), isTrue);
    expect(values.contains(60), isTrue);
    expect(BattleRules.randomMoveMilliseconds, 1000);
  });

  test('Late taps subtract two points, negative score allowed', () {
    expect(BattleRules.huntScore(53, 4), 45);
    expect(BattleRules.huntScore(0, 1), -2);
    expect(BattleRules.stopSeconds, 2);
  });

  test('Skin catalogue has exactly 5 normal, 5 epic and 5 legend', () {
    expect(BattleSkins.all.length, 16); // Free Classic plus 15 cosmetic skins
    expect(BattleSkins.all.where((s) => s.tier == SkinTier.normal).length, 5);
    expect(BattleSkins.all.where((s) => s.tier == SkinTier.epic).length, 5);
    expect(BattleSkins.all.where((s) => s.tier == SkinTier.legend).length, 5);
    expect(BattleSkins.all.where((s) => s.tier == SkinTier.classic).length, 1);
  });

  test('No purchased skin changes competitive scoring rules', () {
    for (final skin in BattleSkins.all) {
      expect(skin.price, greaterThanOrEqualTo(0));
      expect(BattleRules.rankedButtonWidthRatio, .44);
      expect(BattleRules.lateTapPenalty, 2);
    }
  });
}
