class Tile {
  final int value;
  final bool mergedThisMove;

  const Tile({
    required this.value,
    this.mergedThisMove = false,
  });

  const Tile.empty() : this(value: 0, mergedThisMove: false);

  bool get isEmpty => value == 0;

  bool get isNotEmpty => value != 0;

  Tile copyWith({
    int? value,
    bool? mergedThisMove,
  }) {
    return Tile(
      value: value ?? this.value,
      mergedThisMove: mergedThisMove ?? this.mergedThisMove,
    );
  }

  @override
  String toString() => 'Tile(value: $value, merged: $mergedThisMove)';
}
