import 'package:flutter/material.dart';
import 'package:my_2048_game/features/auth/model/login_model.dart';

class LoginViewModel extends ChangeNotifier {
  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Controllers for text fields (UI state, but we centralize them here)
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;

  // Example: injected dependency (fake here for now)
  // final AuthRepository _authRepository;
  // LoginViewModel(this._authRepository);

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> submit() async {
    // Validate form
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _isLoading = true;
    notifyListeners();

    try {
      final credentials = LoginData(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // TODO: call your auth service / repository here
      // await _authRepository.login(credentials);

      await Future.delayed(const Duration(seconds: 1)); // fake delay

      // If successful, you might navigate from outside the VM,
      // or expose some "success" state.

    } catch (e) {
      // TODO: handle error, set an error message field, etc.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
