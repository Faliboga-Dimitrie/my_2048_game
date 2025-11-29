import 'package:flutter/material.dart';
import 'package:my_2048_game/features/auth/view_model/login_vm.dart';
import 'package:my_2048_game/features/local_play/model/local_user.dart';
import 'package:my_2048_game/features/local_play/provider/user_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<UserSession>();

    return Consumer<LoginViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: vm.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: vm.emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: vm.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: vm.passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          vm.obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: vm.togglePasswordVisibility,
                      ),
                    ),
                    obscureText: vm.obscurePassword,
                    validator: vm.validatePassword,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final success = await vm.submit();
                            if (success && context.mounted) {
                              session.setUser(LocalUser(username: 'mock_user'));
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/home');
                            } else if (vm.errorMessage != null &&
                                context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(vm.errorMessage!)),
                              );
                            }
                          },
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Login'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/register');
                    },
                    child: const Text("Don't have an account? Register"),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: go to ForgotPassword view (navigation only)
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
