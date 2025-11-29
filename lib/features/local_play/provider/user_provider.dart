import 'package:flutter/foundation.dart';
import 'package:my_2048_game/features/local_play/model/local_user.dart';

class UserSession extends ChangeNotifier {
  LocalUser? currentUser;

  void setUser(LocalUser user) {
    currentUser = user;
    notifyListeners();
  }

  void clear() {
    currentUser = null;
    notifyListeners();
  }
}
