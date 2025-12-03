import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to 2048')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Let\'s get started!:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20), 
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/local_play'),
              child: const Text('1. Play as guest'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('2. Log in as player'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('3. Register as player'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/debug-db'),
              child: const Text('4. See local players'), // named like this so the debug screen is not obvious
            ),
          ],
        ),
      ),
    );
  }
}
