import 'package:my_2048_game/features/game/model/board.dart';
import 'package:my_2048_game/features/game/model/tile.dart';

String serializeBoard(Board board) {
  return board.cells.map((t) => t.value.toString()).join(',');
}

Board deserializeBoard(String data, {required int size}) {
  final parts = data.split(',');
  if (parts.length != size * size) {
    throw ArgumentError('Invalid boardState length: ${parts.length}');
  }

  final tiles = parts
      .map((p) => int.parse(p))
      .map((v) => Tile(value: v))
      .toList(growable: false);

  return Board(size: size, cells: tiles);
}