import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> register(String email, String password);
  Future<bool> login(String email, String password);
  Future<void> logout();
  Future<bool> get isLoggedIn;
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  static const String _userPrefix = 'user_';
  static const String _sessionKey = 'current_user_email';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> register(String email, String password) async {
    final key = _getUserKey(email);
    final existingUser = await secureStorage.read(key: key);
    if (existingUser != null) {
      throw Exception('User already exists');
    }

    await secureStorage.write(key: key, value: password);
  }

  @override
  Future<bool> login(String email, String password) async {
    final key = _getUserKey(email);
    final storedPassword = await secureStorage.read(key: key);

    if (storedPassword == password) {
      await sharedPreferences.setString(_sessionKey, email);
      return true;
    }
    return false;
  }

  @override
  Future<void> logout() async {
    await sharedPreferences.remove(_sessionKey);
  }

  @override
  Future<bool> get isLoggedIn async {
    return sharedPreferences.getString(_sessionKey) != null;
  }

  String _getUserKey(String email) => '$_userPrefix$email';
}
