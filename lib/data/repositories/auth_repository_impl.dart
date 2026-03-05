import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/local/auth/auth_local_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.localDataSource});

  @override
  Future<void> signUp(String email, String password) async {
    await localDataSource.register(email, password);
  }

  @override
  Future<bool> login(String email, String password) async {
    return await localDataSource.login(email, password);
  }

  @override
  Future<void> logout() async {
    await localDataSource.logout();
  }

  @override
  Future<bool> checkAuthStatus() async {
    return await localDataSource.isLoggedIn;
  }
}
