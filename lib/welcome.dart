import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold oferă structura de bază a unei pagini (AppBar, Body, FloatingActionButton, etc.).
    // Este similar cu Scaffold din Jetpack Compose.
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to 2048 Demo')),
      body: Center(
        // Column este echivalentul Column din Jetpack Compose.
        // Aranjează copiii pe verticală.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'What do you want to do?:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20), // Spacer vertical
            // Navigare simplă folosind rute denumite
            // Navigator.pushNamed este similar cu navController.navigate("route")
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home'),
              child: const Text('1. Log in as guest'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('2. Log in as player'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: const Text('3. Register as player'),
            ),
          ],
        ),
      ),
    );
  }
}
