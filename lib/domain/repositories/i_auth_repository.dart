abstract class IAuthRepository {
  Future<void> signUp(String email, String password);
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<bool> checkAuthStatus();
}
