import 'package:flutter/material.dart';
import 'package:my_2048_game/features/auth/service/auth_api_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthApiService _authApi;
  LoginViewModel(this._authApi);

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get obscurePassword => _obscurePassword;
  String? get errorMessage => _errorMessage;

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

  Future<bool> submit() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authApi.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      debugPrint('Logged in with token: $token');
      clearForm();
      return true;
    } catch (e) {
      _errorMessage = 'Login failed';
      debugPrint(e.toString());
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
