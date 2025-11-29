import 'package:flutter/material.dart';
import 'package:my_2048_game/core/db/app_database.dart';
import 'package:my_2048_game/features/auth/view_model/login_vm.dart';
import 'package:my_2048_game/features/auth/view_model/register_vm.dart';
import 'package:my_2048_game/core/my_app.dart';
import 'package:provider/provider.dart';
import 'package:my_2048_game/features/auth/service/auth_api_service.dart';

void main() {
  final db = AppDatabase();
  final authApi = AuthApiService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(authApi),
        ),
        ChangeNotifierProvider(
          create: (_) => RegisterViewModel(authApi),
        ),
        // later: LocalPlayViewModel, GameViewModel, etc. using db
      ],
      child: const MyApp(),
    ),
  );
}

