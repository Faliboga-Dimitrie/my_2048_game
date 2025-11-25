import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              'Alege un concept de testat:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20), // Spacer vertical
            // Navigare simplă folosind rute denumite
            // Navigator.pushNamed este similar cu navController.navigate("route")
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/layout'),
              child: const Text('1. Layout & Stateless (7.3)'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/interactive'),
              child: const Text('2. Interactivitate & State (7.4)'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/list'),
              child: const Text('3. Liste & Navigare cu Args (7.4.3 & 7.5)'),
            ),
          ],
        ),
      ),
    );
  }
}