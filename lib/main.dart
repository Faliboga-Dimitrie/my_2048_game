import 'package:flutter/material.dart';
import 'package:my_2048_game/core/db/app_database.dart';
import 'package:my_2048_game/features/auth/view_model/login_vm.dart';
import 'package:my_2048_game/features/auth/view_model/register_vm.dart';
import 'package:my_2048_game/core/my_app.dart';
import 'package:my_2048_game/features/local_play/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:my_2048_game/features/auth/service/auth_api_service.dart';

void main() {
  final db = AppDatabase();
  final authApi = AuthApiService();
  final userSession = UserSession();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        ChangeNotifierProvider<UserSession>.value(value: userSession),
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(authApi),
        ),
        ChangeNotifierProvider(
          create: (_) => RegisterViewModel(authApi),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
