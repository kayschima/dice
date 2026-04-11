import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/die.dart';

class DiceProvider with ChangeNotifier {
  int _diceCount = 1;
  int _rollCount = 0;
  List<Die> _dice = [const Die()];
  bool _isRolling = false;

  int get diceCount => _diceCount;
  int get rollCount => _rollCount;
  List<Die> get dice => _dice;
  bool get isDiceCountChangeable => _rollCount == 0 && !_isRolling;
  bool get isRolling => _isRolling;

  void setDiceCount(int count) {
    if (!isDiceCountChangeable) return;
    if (count < 1) count = 1;
    if (count > 10) count = 10;
    
    _diceCount = count;
    _resetDice();
    notifyListeners();
  }

  void toggleDieSelection(int index) {
    if (_rollCount == 0 || _isRolling) return;
    
    _dice[index] = _dice[index].copyWith(isSelected: !_dice[index].isSelected);
    notifyListeners();
  }

  Future<void> rollDice() async {
    if (_isRolling) return;
    
    _isRolling = true;
    _rollCount++;
    
    // Set rolling state for not selected dice
    for (int i = 0; i < _dice.length; i++) {
      if (!_dice[i].isSelected) {
        _dice[i] = _dice[i].copyWith(isRolling: true);
      }
    }
    notifyListeners();

    // Simulate 2 seconds animation
    await Future.delayed(const Duration(seconds: 2));

    final random = Random();
    for (int i = 0; i < _dice.length; i++) {
      if (!_dice[i].isSelected) {
        _dice[i] = _dice[i].copyWith(
          value: random.nextInt(6) + 1,
          isRolling: false,
        );
      }
    }
    
    _isRolling = false;
    notifyListeners();
  }

  void reset() {
    _rollCount = 0;
    _isRolling = false;
    _resetDice();
    notifyListeners();
  }

  void _resetDice() {
    _dice = List.generate(_diceCount, (_) => const Die());
  }
}
