import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_2048_game/core/db/app_database.dart';

class DebugDatabaseScreen extends StatelessWidget {
  const DebugDatabaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Debug'),
      ),
      body: FutureBuilder<_DbSnapshot>(
        future: _loadSnapshot(db),
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

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User: ${user.username} (id: ${user.id})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
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
