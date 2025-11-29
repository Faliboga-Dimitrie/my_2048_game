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

  /// Creates a board with given [size] and [cells].
  /// [cells] must have length == size * size.
  const Board({
    this.size = 4,
    required this.cells,
  }) : assert(cells.length == size * size);

  /// Creates an empty board (all tiles value = 0).
  factory Board.empty({int size = 4}) {
    return Board(
      size: size,
      cells: List<Tile>.filled(size * size, const Tile.empty(), growable: false),
    );
  }

  /// Helper to convert (row, col) into index in the 1D [cells] list.
  int index(int row, int col) => row * size + col;

  /// Get tile at [row], [col].
  Tile tileAt(int row, int col) => cells[index(row, col)];

  /// Returns a new board with tile at [row], [col] replaced.
  Board setTile(int row, int col, Tile tile) {
    final newCells = List<Tile>.from(cells);
    newCells[index(row, col)] = tile;
    return Board(size: size, cells: newCells);
  }

  /// Clears all merged flags and returns a new Board instance.
  Board resetMergeFlags() {
    final newCells = cells
        .map((tile) => tile.mergedThisMove ? tile.copyWith(mergedThisMove: false) : tile)
        .toList();
    return Board(size: size, cells: newCells);
  }

  /// Spawns a new tile (2 or 4) in a random empty position.
  /// Returns a new board.
  Board spawnRandomTile() {
    // TODO: implement:
    // 1. Collect indices of tiles with value == 0.
    final emptyIndices = <int>[];
    for (var i = 0; i < cells.length; i++) {
      if (cells[i].isEmpty) {
        emptyIndices.add(i);
      }
    }
    // 2. If none, return this.
    if (emptyIndices.isEmpty) {
      return this;
    }
    // 3. Pick random empty cell.
    // A simple random based on current time.
    final spawnIndex = emptyIndices[DateTime.now().millisecondsSinceEpoch % emptyIndices.length];
    // 4. Insert new Tile(value: 2 or 4).
    final newValue = (DateTime.now().millisecondsSinceEpoch % 10 == 0) ? 4 : 2;
    final newCells = List<Tile>.from(cells);
    newCells[spawnIndex] = Tile(value: newValue);
    return Board(size: size, cells: newCells);
  }

  /// Executes a move in the given [direction] with the given [mergeMode]
  /// and returns a [MoveResult].
  MoveResult move(Direction direction, MergeMode mergeMode) {
    int gainedScore = 0;
    bool moved = false;
    // TODO: implement:
    // - Reset merge flags
    var resetBoard = resetMergeFlags();
    // - Slide tiles in given direction
    switch (direction) {
      case Direction.up:
      for (var c = 0; c < size; c++) {
          for (var r = 1; r < size; r++) {
            final currentTile = resetBoard.tileAt(r, c);
            if (currentTile.isEmpty) continue;
            var targetRow = r;
            while (targetRow > 0) {
              final aboveTile = resetBoard.tileAt(targetRow - 1, c);
              if (aboveTile.isEmpty) {
                targetRow--;
              } else if (aboveTile.value == currentTile.value && !aboveTile.mergedThisMove && !currentTile.mergedThisMove) {
                // Merge
                final mergedTile = Tile(value: aboveTile.value * 2, mergedThisMove: true);
                gainedScore += mergedTile.value;
                moved = true;
                resetBoard = resetBoard
                    .setTile(targetRow - 1, c, mergedTile)
                    .setTile(r, c, const Tile.empty());
                break;
              } else {
                break;
              }
            }
            if (targetRow != r) {
              resetBoard = resetBoard
                  .setTile(targetRow, c, currentTile)
                  .setTile(r, c, const Tile.empty());
            }
          }
        }
        break;
      case Direction.down:
        for (var c = 0; c < size; c++) {
          for (var r = size - 2; r >= 0; r--) {
            final currentTile = resetBoard.tileAt(r, c);
            if (currentTile.isEmpty) continue;
            var targetRow = r;
            while (targetRow < size - 1) {
              final belowTile = resetBoard.tileAt(targetRow + 1, c);
              if (belowTile.isEmpty) {
                targetRow++;
              } else if (belowTile.value == currentTile.value && !belowTile.mergedThisMove && !currentTile.mergedThisMove) {
                // Merge
                final mergedTile = Tile(value: belowTile.value * 2, mergedThisMove: true);
                gainedScore += mergedTile.value;
                moved = true;
                resetBoard = resetBoard
                    .setTile(targetRow + 1, c, mergedTile)
                    .setTile(r, c, const Tile.empty());
                break;
              } else {
                break;
              }
            }
            if (targetRow != r) {
              resetBoard = resetBoard
                  .setTile(targetRow, c, currentTile)
                  .setTile(r, c, const Tile.empty());
            }
          }
        }
        break;
      case Direction.left:

      case Direction.right:
        
        break;
    }
    // - Spawn random tile if something moved
    if (moved) {
      resetBoard = resetBoard.spawnRandomTile();
    }
    // - Check game over
    final isGameOver = !resetBoard.hasMovesLeft();
    return MoveResult(
      newBoard: resetBoard,
      gainedScore: gainedScore,
      moved: gainedScore > 0, // Simplified; should check if any tile actually moved
      isGameOver: isGameOver,
    );
  }

  /// Returns true if there is at least one legal move (for game over check).
  bool hasMovesLeft() {
    // TODO: implement:
    // - If any tile is empty => true
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (tileAt(r, c).isEmpty) {
          return true;
        }
      }
    }
    // - Else, if any adjacent tiles can merge => true
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final currentTile = tileAt(r, c);
        // Check right
        if (c < size - 1) {
          final rightTile = tileAt(r, c + 1);
          if (currentTile.value == rightTile.value) {
            return true;
          }
        }
        // Check down
        if (r < size - 1) {
          final downTile = tileAt(r + 1, c);
          if (currentTile.value == downTile.value) {
            return true;
          }
        }
      }
    }
    // - Otherwise => false
    return false;
  }

  /// Simple debug print of the board.
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
