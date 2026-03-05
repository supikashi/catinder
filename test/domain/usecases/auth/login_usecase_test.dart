import 'package:catinder/domain/repositories/i_auth_repository.dart';
import 'package:catinder/domain/usecases/auth/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUseCase loginUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    loginUseCase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  group('LoginUseCase', () {
    test('should return true when login is successful', () async {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => true);

      final result = await loginUseCase(tEmail, tPassword);

      expect(result, true);
      verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
    });

    test('should return false when login fails', () async {
      when(() => mockAuthRepository.login(any(), any()))
          .thenAnswer((_) async => false);

      final result = await loginUseCase(tEmail, tPassword);

      expect(result, false);
      verify(() => mockAuthRepository.login(tEmail, tPassword)).called(1);
    });

    test('should throw Exception when email is empty', () async {
      expect(() => loginUseCase('', tPassword), throwsA(isA<Exception>()));
      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    test('should throw Exception when password is empty', () async {
      expect(() => loginUseCase(tEmail, ''), throwsA(isA<Exception>()));
      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    test('should throw Exception when email format is invalid', () async {
      expect(() => loginUseCase('invalid-email', tPassword),
          throwsA(isA<Exception>()));
      verifyNever(() => mockAuthRepository.login(any(), any()));
    });

    test('should throw Exception when password is too short', () async {
      expect(() => loginUseCase(tEmail, '12345'), throwsA(isA<Exception>()));
      verifyNever(() => mockAuthRepository.login(any(), any()));
    });
  });
}
