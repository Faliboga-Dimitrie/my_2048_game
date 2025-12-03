import 'package:flutter/foundation.dart';
import 'package:my_2048_game/core/db/app_database.dart';
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
}
