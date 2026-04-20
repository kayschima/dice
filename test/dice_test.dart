import 'package:flutter_test/flutter_test.dart';
import 'package:kayschima_dice/providers/dice_provider.dart';

void main() {
  group('DiceProvider Tests', () {
    test('Initial state should be correct', () {
      final provider = DiceProvider();
      expect(provider.diceCount, 1);
      expect(provider.rollCount, 0);
      expect(provider.dice.length, 1);
      expect(provider.isRolling, false);
      expect(provider.isDiceCountChangeable, true);
      expect(provider.dice[0].value, 0);
      expect(provider.totalEyes, 0);
    });

    test('Setting dice count updates state', () {
      final provider = DiceProvider();
      provider.setDiceCount(3);
      expect(provider.diceCount, 3);
      expect(provider.dice.length, 3);
      expect(provider.dice.every((die) => die.value == 0), true);
      expect(provider.totalEyes, 0);

      provider.setDiceCount(15); // Should be capped at 10
      expect(provider.diceCount, 10);
      expect(provider.dice.every((die) => die.value == 0), true);
      expect(provider.totalEyes, 0);

      provider.setDiceCount(0); // Should be floor at 1
      expect(provider.diceCount, 1);
      expect(provider.dice[0].value, 0);
      expect(provider.totalEyes, 0);
    });

    test('Rolling dice increments rollCount and eventually updates dice values', () async {
      final provider = DiceProvider();
      
      // Use a shorter delay for testing if possible or just wait
      final future = provider.rollDice();
      
      expect(provider.isRolling, true);
      expect(provider.rollCount, 1);
      
      await future;
      
      expect(provider.isRolling, false);
      expect(provider.dice[0].value, inInclusiveRange(1, 6));
      expect(provider.totalEyes, inInclusiveRange(1, 6));
    });

    test('Toggle selection should work after first roll', () async {
      final provider = DiceProvider();
      
      // Selection should not work before first roll
      provider.toggleDieSelection(0);
      expect(provider.dice[0].isSelected, false);
      
      await provider.rollDice();
      
      provider.toggleDieSelection(0);
      expect(provider.dice[0].isSelected, true);
      
      provider.toggleDieSelection(0);
      expect(provider.dice[0].isSelected, false);
    });

    test('Dice count should be locked after first roll and unlocked after reset', () async {
      final provider = DiceProvider();
      expect(provider.isDiceCountChangeable, true);
      
      provider.setDiceCount(3);
      expect(provider.diceCount, 3);
      
      await provider.rollDice();
      expect(provider.rollCount, 1);
      expect(provider.isDiceCountChangeable, false);
      
      // Try to change dice count when locked
      provider.setDiceCount(5);
      expect(provider.diceCount, 3); // Should still be 3
      
      provider.reset();
      expect(provider.rollCount, 0);
      expect(provider.isDiceCountChangeable, true);
      expect(provider.totalEyes, 0);

      provider.setDiceCount(10);
      expect(provider.diceCount, 10);
      expect(provider.totalEyes, 0);
    });

    test('Reset should clear everything', () async {
      final provider = DiceProvider();
      provider.setDiceCount(3);
      await provider.rollDice();
      provider.toggleDieSelection(0);
      
      provider.reset();
      
      expect(provider.rollCount, 0);
      expect(provider.dice.length, 3);
      expect(provider.dice[0].isSelected, false);
      expect(provider.dice.every((die) => die.value == 0), true);
      expect(provider.isRolling, false);
      expect(provider.totalEyes, 0);
    });
  });
}
