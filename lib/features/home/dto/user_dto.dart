class UserStats {
  final int bestScore;
  final int gamesPlayed;
  final int totalMoves;

  const UserStats({
    required this.bestScore,
    required this.gamesPlayed,
    required this.totalMoves,
  });

  static const empty = UserStats(bestScore: 0, gamesPlayed: 0, totalMoves: 0);
}