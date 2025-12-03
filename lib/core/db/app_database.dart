import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Users, Games],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2; // was 1

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from == 1) {
            await m.addColumn(games, games.boardSize );
            await m.addColumn(games, games.mergeMode );
          }
        },
      );

  // ---------------- USER QUERIES ----------------

  Future<int> createUser(String username) {
    return into(users).insert(
      UsersCompanion.insert(username: username),
    );
  }

  Future<User?> getUserByUsername(String username) {
    return (select(users)..where((u) => u.username.equals(username)))
        .getSingleOrNull();
  }

  Future<List<User>> getAllUsers() => select(users).get();

  // ---------------- GAME QUERIES ----------------

  Future<int> createGame({
    required int userId,
    required String boardState,
    required int score,
    required int moveCount,
    required int boardSize,
    required int mergeModeIndex,
  }) {
    return into(games).insert(
      GamesCompanion.insert(
        userId: userId,
        boardState: boardState,
        score: Value(score),
        moveCount: Value(moveCount),
        boardSize: Value(boardSize),
        mergeMode: Value(mergeModeIndex),
      ),
    );
  }

  Future<List<Game>> getGamesForUser(int userId) {
    return (select(games)
          ..where((g) => g.userId.equals(userId))
          ..orderBy([
            (g) => OrderingTerm(expression: g.lastPlayedAt, mode: OrderingMode.desc),
          ]))
        .get();
  }
  Future<bool> updateGame(Game game) => update(games).replace(game);

  Future<int> deleteGame(int id) =>
      (delete(games)..where((g) => g.id.equals(id))).go();
}

/// Opens the SQLite DB
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app_database.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
