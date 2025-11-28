import 'package:my_2048_game/core/db/app_database.dart';
import '../model/local_user.dart';

/// Abstraction for local users
abstract class ILocalUserRepository {
  Future<bool> usernameExists(String username);
  Future<LocalUser> createUser(String username);
  Future<LocalUser?> getUser(String username);
  Future<List<LocalUser>> getAllUsers();
}

class DriftLocalUserRepository implements ILocalUserRepository {
  final AppDatabase _db;

  DriftLocalUserRepository(this._db);

  LocalUser _mapDbUserToLocalUser(User user) {
    return LocalUser(username: user.username);
  }

  @override
  Future<bool> usernameExists(String username) async {
    final user = await _db.getUserByUsername(username);
    return user != null;
  }

  @override
  Future<LocalUser> createUser(String username) async {
    // create in DB
    await _db.createUser(username);
    // fetch back (to be sure we have the row)
    final user = await _db.getUserByUsername(username);
    if (user == null) {
      throw Exception('Failed to load user after creation');
    }
    return _mapDbUserToLocalUser(user);
  }

  @override
  Future<LocalUser?> getUser(String username) async {
    final user = await _db.getUserByUsername(username);
    if (user == null) return null;
    return _mapDbUserToLocalUser(user);
  }

  @override
  Future<List<LocalUser>> getAllUsers() async {
    final users = await _db.getAllUsers();
    return users.map(_mapDbUserToLocalUser).toList();
  }
}
