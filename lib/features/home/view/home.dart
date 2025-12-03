import 'package:flutter/material.dart';
import 'package:my_2048_game/features/game/view/board_screen.dart';
import 'package:my_2048_game/features/game/view_model/board_vm.dart';
import 'package:my_2048_game/features/game/model/board.dart';
import 'package:my_2048_game/core/db/app_database.dart';
import 'package:my_2048_game/features/home/Widget/saved_games_sheet.dart';
import 'package:my_2048_game/features/home/dto/leaderboard_dto.dart';
import 'package:my_2048_game/features/home/dto/user_dto.dart';
import 'package:my_2048_game/features/home/view_model/home_vm.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleStartNewGame(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GameBoardScreen()),
    );
  }

  Future<void> _handleLoadSavedGame(BuildContext context) async {
    final homeVm = context.read<HomeViewModel>();
    final db = context.read<AppDatabase>();

    final games = await homeVm.loadSavedGamesForCurrentUser();

    if (!context.mounted) return;

    if (games.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No saved games found')));
      return;
    }

    final selectedGame = await showModalBottomSheet<Game>(
      context: context,
      builder: (_) => SavedGamesSheet(games: games, homeVm: homeVm),
    );

    if (selectedGame == null) {
      return;
    }

    final mergeMode = MergeMode.values[selectedGame.mergeMode];

    final boardVm = BoardViewModel(
      db: db,
      userId: selectedGame.userId,
      mergeMode: mergeMode,
      initialGame: selectedGame,
      initialSize: selectedGame.boardSize,
    );

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameBoardScreen(viewModel: boardVm)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final username = homeVm.currentUser?.username ?? 'mock_user';

    return Scaffold(
      appBar: AppBar(title: const Text('2048'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Game Controls Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Game',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleStartNewGame(context),
                        child: const Text('Start New Game'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleLoadSavedGame(context),
                        child: const Text('Load Saved Game'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Statistics Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '$username\'s Statistics',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<UserStats>(
                      future: homeVm.loadStatsForCurrentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final stats = snapshot.data ?? UserStats.empty;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                const Text(
                                  'Best Score',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${stats.bestScore}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Games Played',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${stats.gamesPlayed}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text(
                                  'Total Moves',
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${stats.totalMoves}',
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Leaderboard Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Leaderboard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: FutureBuilder<List<LeaderboardEntry>>(
                        future: homeVm.loadLeaderboard(limit: 10),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final entries =
                              snapshot.data ?? const <LeaderboardEntry>[];

                          if (entries.isEmpty) {
                            return const Center(child: Text('No scores yet'));
                          }

                          return ListView.builder(
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final entry = entries[index];
                              return ListTile(
                                leading: Text('${index + 1}'),
                                title: Text(entry.username),
                                subtitle: Text(
                                  'Games played: ${entry.gamesPlayed}',
                                ),
                                trailing: Text('${entry.bestScore}'),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
