import 'package:flutter/foundation.dart';
import 'package:my_2048_game/core/db/app_database.dart';
import 'package:my_2048_game/features/game/data/board_dao.dart';
import 'package:my_2048_game/features/game/model/board.dart';

class BoardViewModel extends ChangeNotifier {
  final AppDatabase _db;
  final int _userId;
  final MergeMode _mergeMode;

  Board _board;
  int _score;
  int _moveCount;
  bool _isGameOver;

  Game? _currentGameRow; // DB row for this session, if any

  BoardViewModel({
    required AppDatabase db,
    required int userId,
    int initialSize = 4,
    MergeMode mergeMode = MergeMode.classic,
    Game? initialGame, // if you come from "load game"
  })  : _db = db,
        _userId = userId,
        _mergeMode = mergeMode,
        _score = initialGame?.score ?? 0,
        _moveCount = initialGame?.moveCount ?? 0,
        _isGameOver = false, // you can also read this from game if you add a flag
        _currentGameRow = initialGame,
        _board = initialGame != null
            ? deserializeBoard(initialGame.boardState, size: 4) // or store size in DB
            : Board.empty(size: initialSize);

  Board get board => _board;
  int get score => _score;
  int get moveCount => _moveCount;
  bool get isGameOver => _isGameOver;
  MergeMode get mergeMode => _mergeMode;

  /// Starts a new game and creates a DB row for it.
  Future<void> newGame() async {
    _board = Board.empty(size: _board.size)
        .spawnRandomTile()
        .spawnRandomTile();
    _score = 0;
    _moveCount = 0;
    _isGameOver = false;

    final boardState = serializeBoard(_board);

    // create row in DB
    final gameId = await _db.createGame(
      userId: _userId,
      boardState: boardState,
      score: _score,
      moveCount: _moveCount,
    );

    // Build in-memory Game row (Drift's Game class)
    _currentGameRow = Game(
      id: gameId,
      userId: _userId,
      boardState: boardState,
      score: _score,
      moveCount: _moveCount,
      createdAt: DateTime.now(),
      lastPlayedAt: DateTime.now(),
    );

    notifyListeners();
  }

  /// Called when the user performs a move.
  Future<void> onMove(Direction direction) async {
    if (_isGameOver) return;

    final result = _board.move(direction, _mergeMode);

    if (!result.moved) {
      // No change – no DB update needed.
      return;
    }

    _board = result.newBoard;
    _score += result.gainedScore;
    _moveCount += 1;
    _isGameOver = result.isGameOver;

    await _saveToDb();
    notifyListeners();
  }

  /// Saves the current game state into the DB.
  Future<void> _saveToDb() async {
    if (_currentGameRow == null) return;

    final boardState = serializeBoard(_board);

    final updated = Game(
      id: _currentGameRow!.id,
      userId: _currentGameRow!.userId,
      boardState: boardState,
      score: _score,
      moveCount: _moveCount,
      createdAt: _currentGameRow!.createdAt,
      lastPlayedAt: DateTime.now(),
    );

    await _db.updateGame(updated);
    _currentGameRow = updated;
  }

  /// If you need to load an existing game manually (e.g. from a "load game" list)
  void loadFromGame(Game game) {
    _currentGameRow = game;
    _board = deserializeBoard(game.boardState, size: _board.size);
    _score = game.score;
    _moveCount = game.moveCount;
    _isGameOver = false; // or derive from DB if you store it
    notifyListeners();
  }
}
