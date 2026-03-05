import '../../repositories/i_auth_repository.dart';

class CheckAuthStatusUseCase {
  final IAuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.checkAuthStatus();
  }
}
