import 'package:catinder/domain/repositories/i_auth_repository.dart';
import 'package:catinder/domain/usecases/auth/sign_up_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late SignUpUseCase signUpUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    signUpUseCase = SignUpUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  group('SignUpUseCase', () {
    test('should call repository.signUp when email and password are valid',
        () async {
      when(() => mockAuthRepository.signUp(any(), any()))
          .thenAnswer((_) async {});

      await signUpUseCase(tEmail, tPassword);

      verify(() => mockAuthRepository.signUp(tEmail, tPassword)).called(1);
    });

    test('should throw Exception when email is empty', () async {
      expect(() => signUpUseCase('', tPassword), throwsA(isA<Exception>()));
      verifyNever(() => mockAuthRepository.signUp(any(), any()));
    });

    test('should throw Exception when password is empty', () async {
      expect(() => signUpUseCase(tEmail, ''), throwsA(isA<Exception>()));
      verifyNever(() => mockAuthRepository.signUp(any(), any()));
    });

    test('should throw Exception when email format is invalid', () async {
      expect(() => signUpUseCase('invalid-email', tPassword),
          throwsA(isA<Exception>()));
      verifyNever(() => mockAuthRepository.signUp(any(), any()));
    });

    test('should throw Exception when password is too short', () async {
      expect(() => signUpUseCase(tEmail, '12345'), throwsA(isA<Exception>()));
      verifyNever(() => mockAuthRepository.signUp(any(), any()));
    });

    test('should propagate exception from repository', () async {
      when(() => mockAuthRepository.signUp(any(), any()))
          .thenThrow(Exception('User already exists'));

      expect(() => signUpUseCase(tEmail, tPassword), throwsA(isA<Exception>()));
      verify(() => mockAuthRepository.signUp(tEmail, tPassword)).called(1);
    });
  });
}
