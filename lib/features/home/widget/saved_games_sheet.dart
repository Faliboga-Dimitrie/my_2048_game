import 'package:flutter/material.dart';
import 'package:my_2048_game/features/game/model/board.dart';
import 'package:my_2048_game/features/home/view_model/home_vm.dart';
import 'package:my_2048_game/core/db/app_database.dart';

class SavedGamesSheet extends StatefulWidget {
  final List<Game> games;
  final HomeViewModel _homeVm;

  const SavedGamesSheet({super.key, required this.games, required HomeViewModel homeVm}) : _homeVm = homeVm;

  @override
  State<SavedGamesSheet> createState() => _SavedGamesSheetState();
}

class _SavedGamesSheetState extends State<SavedGamesSheet> {
  late List<Game> _games;

  @override
  void initState() {
    super.initState();
    _games = List<Game>.from(widget.games);
  }

  String _modeLabelFor(int mergeModeIndex) {
    final mode = MergeMode.values[mergeModeIndex];
    switch (mode) {
      case MergeMode.classic:
        return 'Classic';
      case MergeMode.cascade:
        return 'Cascade';
    }
  }

  Future<void> _deleteGame(BuildContext context, Game game, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete saved game?'),
        content: const Text(
            'This will permanently delete this saved game. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final homeVm = widget._homeVm;
    await homeVm.deleteGameById(game.id);

    if (!mounted) return;

    setState(() {
      _games.removeAt(index);
    });

    // If there are no games left, just close the bottom sheet
    if (_games.isEmpty) {
      Navigator.of(context).pop();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved game deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _games.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No saved games')),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemCount: _games.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final game = _games[index];
                final modeLabel = _modeLabelFor(game.mergeMode);

                return ListTile(
                  title: Text(
                    'Score: ${game.score}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Size: ${game.boardSize} • Mode: $modeLabel\n'
                    'Moves: ${game.moveCount} • Last played: ${game.lastPlayedAt}',
                  ),
                  onTap: () {
                    Navigator.of(context).pop<Game>(game);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete this saved game',
                    onPressed: () => _deleteGame(context, game, index),
                  ),
                );
              },
            ),
    );
  }
}
