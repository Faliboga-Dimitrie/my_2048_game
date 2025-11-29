import 'package:flutter/material.dart';
import 'package:my_2048_game/debug/debug_database_screen.dart';
import 'package:my_2048_game/features/home/view/home.dart';
import 'package:my_2048_game/core/welcome.dart';
import 'package:my_2048_game/features/auth/view/login_view.dart';
import 'package:my_2048_game/features/auth/view/register_view.dart';
import 'package:my_2048_game/features/local_play/view/local_player_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Capitolul 7',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/local_play': (context) => const LocalUserScreen(),
        '/debug-db': (context) => const DebugDatabaseScreen(),
      },
    );
  }
}
