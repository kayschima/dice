class Die {
  final int value;
  final bool isSelected;
  final bool isRolling;

  const Die({
    this.value = 0,
    this.isSelected = false,
    this.isRolling = false,
  });

  Die copyWith({
    int? value,
    bool? isSelected,
    bool? isRolling,
  }) {
    return Die(
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
      isRolling: isRolling ?? this.isRolling,
    );
  }
}
