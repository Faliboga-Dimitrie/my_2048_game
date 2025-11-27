import 'package:flutter/material.dart';
import 'package:my_2048_game/features/auth/veiwModel/login_vm.dart';
import 'package:my_2048_game/my_app.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LoginViewModel(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
