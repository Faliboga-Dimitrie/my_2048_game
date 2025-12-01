import 'tile.dart';

enum Direction { up, down, left, right }

enum MergeMode { classic, cascade }

class MoveResult {
  final Board newBoard;
  final int gainedScore;
  final bool moved;
  final bool isGameOver;

  const MoveResult({
    required this.newBoard,
    required this.gainedScore,
    required this.moved,
    required this.isGameOver,
  });
}

class Board {
  final int size;
  final List<Tile> cells;

  const Board({
    this.size = 4,
    required this.cells,
  }) : assert(cells.length == size * size);

  factory Board.empty({int size = 4}) {
    return Board(
      size: size,
      cells: List<Tile>.filled(size * size, const Tile.empty(), growable: false),
    );
  }
  /// Converts (row, col) to linear index.
  int index(int row, int col) => row * size + col;

  /// Get tile at [row], [col].
  Tile tileAt(int row, int col) => cells[index(row, col)];

  Board resetMergeFlags() {
    final newCells = cells
        .map((tile) => tile.mergedThisMove ? tile.copyWith(mergedThisMove: false) : tile)
        .toList();
    return Board(size: size, cells: newCells);
  }

  Board spawnRandomTile() {
    final emptyIndices = <int>[];
    for (var i = 0; i < cells.length; i++) {
      if (cells[i].isEmpty) {
        emptyIndices.add(i);
      }
    }

    if (emptyIndices.isEmpty) {
      return this;
    }

    final spawnIndex = emptyIndices[DateTime.now().millisecondsSinceEpoch % emptyIndices.length];
    final newValue = (DateTime.now().millisecondsSinceEpoch % 10 == 0) ? 4 : 2;
    final newCells = List<Tile>.from(cells);
    newCells[spawnIndex] = Tile(value: newValue);
    return Board(size: size, cells: newCells);
  }

  MoveResult move(Direction direction, MergeMode mergeMode) {
  int gainedScore = 0;
  bool moved = false;

  final Board baseBoard = resetMergeFlags();

  final newCells = List<Tile>.from(baseBoard.cells);

  Tile tileAtRC(int row, int col) => newCells[index(row, col)];
  void setTileRC(int row, int col, Tile tile) {
    newCells[index(row, col)] = tile;
  }

  bool isEmpty(Tile t) => t.isEmpty; 

  switch (direction) {
    case Direction.up:
      for (var j = 0; j < size; ++j) {
        for (var i = size - 1; i >= 1; --i) {
          final current = tileAtRC(i, j);
          if (isEmpty(current)) continue;

          switch (mergeMode) {
            case MergeMode.classic:
              final above = tileAtRC(i - 1, j);

              if (isEmpty(above)) {
                setTileRC(i - 1, j, current);
                setTileRC(i, j, const Tile.empty());
                moved = true;
                i = size - 1;
              } else if (above.value == current.value && !current.mergedThisMove) {
                final mergedValue = current.value * 2;
                gainedScore += mergedValue;
                setTileRC(
                  i - 1,
                  j,
                  above.copyWith(
                    value: mergedValue,
                    mergedThisMove: true,
                  ),
                );
                setTileRC(i, j, const Tile.empty());
                moved = true;
                i = size - 1;
              }
              break;

            case MergeMode.cascade:
              final above = tileAtRC(i - 1, j);

              if (isEmpty(above)) {
                setTileRC(i - 1, j, current);
                setTileRC(i, j, const Tile.empty());
                moved = true;
                i = size - 1;
              } else if (above.value == current.value) {
                final mergedValue = current.value * 2;
                gainedScore += mergedValue;
                setTileRC(
                  i - 1,
                  j,
                  above.copyWith(value: mergedValue),
                );
                setTileRC(i, j, const Tile.empty());
                moved = true;
                i = size - 1;
              }
              break;
          }
        }
      }
      break;

    case Direction.down:
      for (var j = 0; j < size; ++j) {
        for (var i = 0; i < size - 1; ++i) {
          final current = tileAtRC(i, j);
          if (isEmpty(current)) continue;

          switch (mergeMode) {
            case MergeMode.classic:
              final below = tileAtRC(i + 1, j);

              if (isEmpty(below)) {
                setTileRC(i + 1, j, current);
                setTileRC(i, j, const Tile.empty());
                moved = true;
                i = 0;
              } else if (below.value == current.value && !current.mergedThisMove) {
                final mergedValue = current.value * 2;
                gainedScore += mergedValue;
                setTileRC(
                  i + 1,
                  j,
                  below.copyWith(
                    value: mergedValue,
                    mergedThisMove: true,
                  ),
                );
                setTileRC(i, j, const Tile.empty());
                moved = true;
                i = 0;
              }
              break;

            case MergeMode.cascade:
              final below = tileAtRC(i + 1, j);

              if (isEmpty(below)) {
                setTileRC(i + 1, j, current);
                setTileRC(i, j, const Tile.empty());
                moved = true;
                i = 0;
              } else if (below.value == current.value) {
                final mergedValue = current.value * 2;
                gainedScore += mergedValue;
                setTileRC(
                  i + 1,
                  j,
                  below.copyWith(value: mergedValue),
                );
                setTileRC(i, j, const Tile.empty());
                moved = true;
                i = 0;
              }
              break;
          }
        }
      }
      break;

    case Direction.left:
      for (var i = 0; i < size; ++i) {
        for (var j = size - 1; j >= 1; --j) {
          final current = tileAtRC(i, j);
          if (isEmpty(current)) continue;

          switch (mergeMode) {
            case MergeMode.classic:
              final left = tileAtRC(i, j - 1);

              if (isEmpty(left)) {
                setTileRC(i, j - 1, current);
                setTileRC(i, j, const Tile.empty());
                moved = true;
                j = size - 1;
              } else if (left.value == current.value && !current.mergedThisMove) {
                final mergedValue = current.value * 2;
                gainedScore += mergedValue;
                setTileRC(
                  i,
                  j - 1,
                  left.copyWith(
                    value: mergedValue,
                    mergedThisMove: true,
                  ),
                );
                setTileRC(i, j, const Tile.empty());
                moved = true;
                j = size - 1;
              }
              break;

            case MergeMode.cascade:
              final left = tileAtRC(i, j - 1);

              if (isEmpty(left)) {
                setTileRC(i, j - 1, current);
                setTileRC(i, j, const Tile.empty());
                moved = true;
                j = size - 1;
              } else if (left.value == current.value) {
                final mergedValue = current.value * 2;
                gainedScore += mergedValue;
                setTileRC(
                  i,
                  j - 1,
                  left.copyWith(value: mergedValue),
                );
                setTileRC(i, j, const Tile.empty());
                moved = true;
                j = size - 1;
              }
              break;
          }
        }
      }
      break;

    case Direction.right:
      for (var i = 0; i < size; ++i) {
        for (var j = 0; j < size - 1; ++j) {
          final current = tileAtRC(i, j);
          if (isEmpty(current)) continue;

          switch (mergeMode) {
            case MergeMode.classic:
              final right = tileAtRC(i, j + 1);

              if (isEmpty(right)) {
                setTileRC(i, j + 1, current);
                setTileRC(i, j, const Tile.empty());
                moved = true;
                j = 0;
              } else if (right.value == current.value && !current.mergedThisMove) {
                final mergedValue = current.value * 2;
                gainedScore += mergedValue;
                setTileRC(
                  i,
                  j + 1,
                  right.copyWith(
                    value: mergedValue,
                    mergedThisMove: true,
                  ),
                );
                setTileRC(i, j, const Tile.empty());
                moved = true;
                j = 0;
              }
              break;

            case MergeMode.cascade:
              final right = tileAtRC(i, j + 1);

              if (isEmpty(right)) {
                setTileRC(i, j + 1, current);
                setTileRC(i, j, const Tile.empty());
                moved = true;
                j = 0;
              } else if (right.value == current.value) {
                final mergedValue = current.value * 2;
                gainedScore += mergedValue;
                setTileRC(
                  i,
                  j + 1,
                  right.copyWith(value: mergedValue),
                );
                setTileRC(i, j, const Tile.empty());
                moved = true;
                j = 0;
              }
              break;
          }
        }
      }
      break;
  }

  Board movedBoard = Board(size: size, cells: newCells);
  final newBoard = movedBoard.spawnRandomTile();
  final isGameOver = !newBoard.hasMovesLeft();

  return MoveResult(
    newBoard: newBoard,
    gainedScore: gainedScore,
    moved: moved,
    isGameOver: isGameOver,
  );
}

bool hasMovesLeft() {
  for (final tile in cells) {
    if (tile.isEmpty) {
      return true;
    }
  }

  for (var row = 0; row < size; row++) {
    for (var col = 0; col < size - 1; col++) {
      if (tileAt(row, col).value == tileAt(row, col + 1).value) {
        return true;
      }
    }
  }

  for (var row = 0; row < size - 1; row++) {
    for (var col = 0; col < size; col++) {
      if (tileAt(row, col).value == tileAt(row + 1, col).value) {
        return true;
      }
    }
  }

  return false;
}

  @override
  String toString() {
    final buffer = StringBuffer();
    for (var r = 0; r < size; r++) {
      final rowValues = <String>[];
      for (var c = 0; c < size; c++) {
        rowValues.add(tileAt(r, c).value.toString().padLeft(4));
      }
      buffer.writeln(rowValues.join());
    }
    return buffer.toString();
  }
}
