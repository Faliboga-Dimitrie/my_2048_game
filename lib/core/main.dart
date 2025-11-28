import 'package:flutter/material.dart';
import 'package:my_2048_game/features/auth/view_model/login_vm.dart';
import 'package:my_2048_game/features/auth/view_model/register_vm.dart';
import 'package:my_2048_game/core/my_app.dart';
import 'package:provider/provider.dart';
import 'package:my_2048_game/features/auth/service/auth_api_service.dart';

void main() {
  final authApi = AuthApiService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel(authApi)),
        ChangeNotifierProvider(create: (_) => RegisterViewModel(authApi)),
      ],
      child: const MyApp(),
    ),
  );
}
