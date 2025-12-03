import 'package:flutter/material.dart';
import 'package:my_2048_game/features/game/view/board_screen.dart';
import 'package:my_2048_game/features/game/view_model/board_vm.dart';
import 'package:my_2048_game/features/game/model/board.dart';
import 'package:my_2048_game/core/db/app_database.dart';
import 'package:my_2048_game/features/home/Widget/saved_games_sheet.dart';
import 'package:my_2048_game/features/home/view_model/home_vm.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _handleStartNewGame(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const GameBoardScreen(),
      ),
    );
  }

  Future<void> _handleLoadSavedGame(BuildContext context) async {
    final homeVm = context.read<HomeViewModel>();
    final db = context.read<AppDatabase>();

    final games = await homeVm.loadSavedGamesForCurrentUser();

    if (!context.mounted) return;

    if (games.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved games found')),
      );
      return;
    }

    final selectedGame = await showModalBottomSheet<Game>(
      context: context,
      builder: (_) => SavedGamesSheet(games: games, homeVm: homeVm),
    );

    if (selectedGame == null) {
      return;
    }

    final boardVm = BoardViewModel(
      db: db,
      userId: selectedGame.userId,
      mergeMode: MergeMode.classic,
      initialGame: selectedGame,
      initialSize: 4, // match your serialize/deserialize assumptions
    );

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameBoardScreen(viewModel: boardVm),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final username = homeVm.currentUser?.username ?? 'mock_user';

    return Scaffold(
      appBar: AppBar(
        title: const Text('2048'),
        centerTitle: true,
      ),
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

            // Statistics Section (still mock for now, can be wired to VM later)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      '$username\'s Statistics',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        Column(
                          children: [
                            Text('Best Score',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            Text('0', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Games Played',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            Text('0', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Games Won',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            Text('0', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ],
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Text('${index + 1}'),
                            title: Text('Player ${index + 1}'),
                            trailing: Text('${(3 - index) * 1000}'),
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
