import 'package:flutter/material.dart';
import 'package:my_2048_game/features/local_play/data/local_player_repository.dart';
import 'package:my_2048_game/features/local_play/view_model/local_player_vm.dart';
import 'package:provider/provider.dart';

import 'package:my_2048_game/core/db/app_database.dart';

class LocalUserScreen extends StatelessWidget {
  const LocalUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the database instance from the top-level Provider
    final db = context.read<AppDatabase>();

    return ChangeNotifierProvider(
      create: (_) => LocalUserViewModel(
        DriftLocalUserRepository(db),
      ),
      child: const _LocalUserView(),
    );
  }
}

class _LocalUserView extends StatelessWidget {
  const _LocalUserView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LocalUserViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Play as Guest'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How do you want to continue?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Toggle between "new user" and "returning user"
            ToggleButtons(
              isSelected: [
                vm.mode == LocalUserMode.newUser,
                vm.mode == LocalUserMode.returning,
              ],
              onPressed: (index) {
                if (index == 0) {
                  vm.setMode(LocalUserMode.newUser);
                } else {
                  vm.setMode(LocalUserMode.returning);
                }
              },
              borderRadius: BorderRadius.circular(8),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text('I am new'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text('I played before'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (vm.mode == LocalUserMode.newUser) ...[
              const Text(
                'Choose a username:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: vm.setNewUsername,
                decoration: const InputDecoration(
                  hintText: 'Enter a new username',
                  border: OutlineInputBorder(),
                ),
              ),
            ] else ...[
              const Text(
                'Enter your previous username:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                onChanged: vm.setReturningUsername,
                decoration: const InputDecoration(
                  hintText: 'Enter existing username',
                  border: OutlineInputBorder(),
                ),
              ),
            ],

            const SizedBox(height: 12),

            if (vm.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  vm.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isLoading
                    ? null
                    : () async {
                        final user = await vm.submit();
                        if (user != null && context.mounted) {
                          // username is valid and saved in DB
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                child: vm.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
