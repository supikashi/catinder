import '../../domain/repositories/i_onboarding_repository.dart';
import '../datasources/local/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements IOnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({required this.localDataSource});

  @override
  Future<bool> get isOnboardingCompleted =>
      localDataSource.isOnboardingCompleted;

  @override
  Future<void> completeOnboarding() => localDataSource.completeOnboarding();
}
