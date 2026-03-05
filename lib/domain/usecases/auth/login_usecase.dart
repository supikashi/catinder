import '../../repositories/i_auth_repository.dart';
import '../../../core/utils/validators.dart';

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<bool> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }

    if (!Validators.isValidEmail(email)) {
      throw Exception('Invalid email format');
    }
    if (!Validators.isValidPassword(password)) {
      throw Exception('Password must be at least 6 characters');
    }

    return await repository.login(email, password);
  }
}
