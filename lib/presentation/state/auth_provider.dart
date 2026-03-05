import 'package:flutter/material.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';

class AuthProvider extends ChangeNotifier {
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final LogoutUseCase logoutUseCase;

  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAuthChecking = true;
  bool get isAuthChecking => _isAuthChecking;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider({
    required this.checkAuthStatusUseCase,
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.logoutUseCase,
  });

  Future<void> checkAuthStatus() async {
    _isAuthChecking = true;
    notifyListeners();

    _isAuthenticated = await checkAuthStatusUseCase();

    _isAuthChecking = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _startLoading();
    try {
      final success = await loginUseCase(email, password);
      if (success) {
        _isAuthenticated = true;
      } else {
        _errorMessage = 'Invalid email or password';
      }
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
    } finally {
      _stopLoading();
    }
    return _isAuthenticated;
  }

  Future<bool> signUp(String email, String password) async {
    _startLoading();
    try {
      await signUpUseCase(email, password);
      final success = await loginUseCase(email, password);
      if (success) {
        _isAuthenticated = true;
      }
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
    } finally {
      _stopLoading();
    }
    return _isAuthenticated;
  }

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceAll('Exception: ', '');
  }

  Future<void> logout() async {
    await logoutUseCase();
    _isAuthenticated = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
