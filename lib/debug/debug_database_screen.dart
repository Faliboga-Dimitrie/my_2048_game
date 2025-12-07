import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_2048_game/core/db/app_database.dart';

class DebugDatabaseScreen extends StatefulWidget {
  const DebugDatabaseScreen({super.key});

  @override
  State<DebugDatabaseScreen> createState() => _DebugDatabaseScreenState();
}

class _DebugDatabaseScreenState extends State<DebugDatabaseScreen> {
  late Future<_DbSnapshot> _futureSnapshot;

  @override
  void initState() {
    super.initState();
    final db = context.read<AppDatabase>();
    _futureSnapshot = _loadSnapshot(db);
  }

  void _reload(AppDatabase db) {
    setState(() {
      _futureSnapshot = _loadSnapshot(db);
    });
  }

  Future<void> _confirmAndDeleteUser(
    BuildContext context,
    AppDatabase db,
    User user,
  ) async {
    // Just in case we accidentally call this for mock_user
    if (user.username == 'mock_user') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete mock_user')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete local user?'),
        content: Text(
          'This will delete "${user.username}" and all their local games.\n'
          'Are you sure?',
        ),
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

    await db.deleteUser(user.id);

    if (!mounted) return;

    _reload(db);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User "${user.username}" deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Players'),
      ),
      body: FutureBuilder<_DbSnapshot>(
        future: _futureSnapshot,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;
          if (data.users.isEmpty) {
            return const Center(child: Text('No users in database.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.users.length,
            itemBuilder: (context, index) {
              final user = data.users[index];
              final games = data.gamesByUserId[user.id] ?? [];

              final isMockUser = user.username == 'mock_user';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'User: ${user.username}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: isMockUser
                                ? 'Cannot delete mock_user'
                                : 'Delete this local user',
                            onPressed: isMockUser
                                ? null
                                : () => _confirmAndDeleteUser(
                                      context,
                                      db,
                                      user,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Saved games: ${games.length}'),
                      const SizedBox(height: 4),
                      for (final game in games.take(3)) // show first 3
                        Text(
                          '- Game ${game.id} | score: ${game.score} | moves: ${game.moveCount}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (games.length > 3)
                        Text(
                          '...and ${games.length - 3} more',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DbSnapshot {
  final List<User> users;
  final Map<int, List<Game>> gamesByUserId;

  _DbSnapshot({
    required this.users,
    required this.gamesByUserId,
  });
}

Future<_DbSnapshot> _loadSnapshot(AppDatabase db) async {
  final users = await db.getAllUsers();

  final Map<int, List<Game>> gamesByUserId = {};

  for (final user in users) {
    final games = await db.getGamesForUser(user.id);
    gamesByUserId[user.id] = games;
  }

  return _DbSnapshot(
    users: users,
    gamesByUserId: gamesByUserId,
  );
}
