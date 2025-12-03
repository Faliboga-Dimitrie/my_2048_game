import 'package:flutter/foundation.dart';
import 'package:my_2048_game/core/db/app_database.dart';
import 'package:my_2048_game/features/home/dto/leaderboard_dto.dart';
import 'package:my_2048_game/features/home/dto/user_dto.dart';
import 'package:my_2048_game/features/local_play/model/local_user.dart';
import 'package:my_2048_game/features/local_play/provider/user_provider.dart';

class HomeViewModel extends ChangeNotifier {
  final AppDatabase _db;
  final UserSession _userSession;

  HomeViewModel({
    required AppDatabase db,
    required UserSession userSession,
  })  : _db = db,
        _userSession = userSession;

  LocalUser? get currentUser => _userSession.currentUser;

  /// For now, only exposing a method to load saved games for the current user.
  Future<List<Game>> loadSavedGamesForCurrentUser() async {
    final user = currentUser;
    if (user == null) return [];
    User dbUser = await _db.getUserByUsername(user.username) as User;
    return _db.getGamesForUser(dbUser.id);
  }

  Future<void> deleteGameById(int id) async {
    await _db.deleteGame(id);
    // If later you cache a list of games in this VM, call notifyListeners() here.
  }

  Future<UserStats> loadStatsForCurrentUser() async {
    final user = currentUser;
    if (user == null) return UserStats.empty;

    final dbUser = await _db.getUserByUsername(user.username);
    if (dbUser == null) return UserStats.empty;

    final games = await _db.getGamesForUser(dbUser.id);
    if (games.isEmpty) return UserStats.empty;

    int bestScore = 0;
    int totalMoves = 0;

    for (final g in games) {
      if (g.score > bestScore) bestScore = g.score;
      totalMoves += g.moveCount;
    }

    return UserStats(
      bestScore: bestScore,
      gamesPlayed: games.length,
      totalMoves: totalMoves,
    );
  }

  /// -------- NEW: LEADERBOARD --------
  ///
  /// Simple leaderboard: highest score per user, sorted desc.
  Future<List<LeaderboardEntry>> loadLeaderboard({int limit = 10}) async {
    final users = await _db.getAllUsers();
    final entries = <LeaderboardEntry>[];

    for (final u in users) {
      final games = await _db.getGamesForUser(u.id);
      if (games.isEmpty) continue;

      int bestScore = 0;
      for (final g in games) {
        if (g.score > bestScore) bestScore = g.score;
      }

      entries.add(
        LeaderboardEntry(
          username: u.username,
          bestScore: bestScore,
          gamesPlayed: games.length,
        ),
      );
    }

    entries.sort((a, b) => b.bestScore.compareTo(a.bestScore));

    if (entries.length > limit) {
      return entries.sublist(0, limit);
    }
    return entries;
  }
}
