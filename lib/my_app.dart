import 'package:flutter/material.dart';
import 'package:my_2048_game/features/home/view/home.dart';
import 'package:my_2048_game/welcome.dart';
import 'package:my_2048_game/features/auth/view/login_view.dart';
import 'package:my_2048_game/features/auth/view/register_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Metoda build este echivalentul funcției @Composable din Jetpack Compose.
  // Ea descrie interfața utilizatorului în funcție de configurația curentă.
  @override
  Widget build(BuildContext context) {
    // MaterialApp este widget-ul rădăcină care configurează tema, rutele și alte setări globale.
    // Similar cu setarea temei (ex: MaterialTheme) la nivelul de sus al ierarhiei în Compose.
    return MaterialApp(
      title: 'Demo Capitolul 7',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      // Definirea rutei inițiale (ecranul de start)
      initialRoute: '/',
      // Harta rutelor (Named Routes - Vezi 7.5.2)
      // Aici definim "Navigation Graph"-ul aplicației.
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        // '/details': (context) => const ProductDetailScreen(),
      },
    );
  }
}
