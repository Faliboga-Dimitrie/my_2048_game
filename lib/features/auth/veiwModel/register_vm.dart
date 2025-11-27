import 'package:flutter/material.dart';
import 'package:my_2048_game/features/auth/service/auth_api_service.dart';

class RegisterViewModel extends ChangeNotifier {
  // Injected dependencies
  final AuthApiService _authApi;
  RegisterViewModel(this._authApi);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  bool _validateForm() {
    if (nameController.text.isEmpty) {
      _errorMessage = 'Name is required';
      return false;
    }
    if (emailController.text.isEmpty || !emailController.text.contains('@')) {
      _errorMessage = 'Valid email is required';
      return false;
    }
    if (passwordController.text.isEmpty || passwordController.text.length < 6) {
      _errorMessage = 'Password must be at least 6 characters';
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      _errorMessage = 'Passwords do not match';
      return false;
    }
    return true;
  }

  Future<bool> register() async {
    _errorMessage = null;

    if (!_validateForm()) {
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _authApi.register(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await Future.delayed(Duration(seconds: 2)); // Simulate network call

      // Handle successful registration
      debugPrint('Registered with token: $token');
      clearForm();
      return true;
    } catch (e) {
      _errorMessage = 'Registration failed';
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
    confirmPasswordController.clear();
    nameController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.dispose();
  }
}
