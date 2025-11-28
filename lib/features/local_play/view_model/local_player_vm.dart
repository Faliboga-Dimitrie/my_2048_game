import 'package:flutter/foundation.dart';
import 'package:my_2048_game/features/local_play/data/local_player_repository.dart';
import '../model/local_user.dart';

enum LocalUserMode { newUser, returning }

class LocalUserViewModel extends ChangeNotifier {
  final ILocalUserRepository _repository;

  LocalUserViewModel(this._repository);

  LocalUserMode mode = LocalUserMode.newUser;

  String newUsername = '';
  String returningUsername = '';
  String? errorMessage;
  bool isLoading = false;

  LocalUser? currentUser; // <- the chosen user (after submit)

  void setMode(LocalUserMode value) {
    mode = value;
    errorMessage = null;
    notifyListeners();
  }

  void setNewUsername(String value) {
    newUsername = value;
    errorMessage = null;
    notifyListeners();
  }

  void setReturningUsername(String value) {
    returningUsername = value;
    errorMessage = null;
    notifyListeners();
  }

  Future<LocalUser?> submit() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (mode == LocalUserMode.newUser) {
        currentUser = await _handleNewUser();
      } else {
        currentUser = await _handleReturningUser();
      }
      return currentUser;
    } catch (e) {
      errorMessage = 'Unexpected error: $e';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<LocalUser?> _handleNewUser() async {
    final username = newUsername.trim();
    if (username.isEmpty) {
      errorMessage = 'Please enter a username.';
      return null;
    }

    final exists = await _repository.usernameExists(username);
    if (exists) {
      errorMessage =
          'This username already exists. Try "I played before" instead.';
      return null;
    }

    final user = await _repository.createUser(username);
    return user;
  }

  Future<LocalUser?> _handleReturningUser() async {
    final username = returningUsername.trim();
    if (username.isEmpty) {
      errorMessage = 'Please enter your previous username.';
      return null;
    }

    final user = await _repository.getUser(username);
    if (user == null) {
      errorMessage = 'No user found with that username.';
      return null;
    }

    return user;
  }
}
