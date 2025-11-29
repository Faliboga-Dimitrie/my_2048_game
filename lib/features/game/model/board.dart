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
    // TODO: implement: return a new Board where all tiles have mergedThisMove = false.
    throw UnimplementedError('resetMergeFlags() not implemented yet');
  }

  /// Spawns a new tile (2 or 4) in a random empty position.
  /// Returns a new board.
  Board spawnRandomTile() {
    // TODO: implement:
    // 1. Collect indices of tiles with value == 0.
    // 2. If none, return this.
    // 3. Pick random empty cell.
    // 4. Insert new Tile(value: 2 or 4).
    throw UnimplementedError('spawnRandomTile() not implemented yet');
  }

  /// Executes a move in the given [direction] with the given [mergeMode]
  /// and returns a [MoveResult].
  MoveResult move(Direction direction, MergeMode mergeMode) {
    // TODO: implement:
    // - Reset merge flags
    // - Slide tiles in given direction
    // - Merge according to mergeMode
    // - Calculate gainedScore
    // - Spawn random tile if something moved
    // - Check game over
    throw UnimplementedError('move() not implemented yet');
  }

  /// Returns true if there is at least one legal move (for game over check).
  bool hasMovesLeft() {
    // TODO: implement:
    // - If any tile is empty => true
    // - Else, if any adjacent tiles can merge => true
    // - Otherwise => false
    throw UnimplementedError('hasMovesLeft() not implemented yet');
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
