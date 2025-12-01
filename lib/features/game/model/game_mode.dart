enum GameMode {
  classic,
  cascade
}

extension GameModeLabel on GameMode {
  String get label {
    switch (this) {
      case GameMode.classic:
        return "Classic";
      case GameMode.cascade:
        return "Cascade";
    }
  }
}
