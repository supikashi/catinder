import '../../repositories/i_auth_repository.dart';
import '../../../core/utils/validators.dart';

class SignUpUseCase {
  final IAuthRepository repository;

  SignUpUseCase(this.repository);

  Future<void> call(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty');
    }
    if (!Validators.isValidPassword(password)) {
      throw Exception('Password must be at least 6 characters');
    }

    if (!Validators.isValidEmail(email)) {
      throw Exception('Invalid email format');
    }

    await repository.signUp(email, password);
  }
}
