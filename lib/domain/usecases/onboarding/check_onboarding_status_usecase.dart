import '../../repositories/i_onboarding_repository.dart';

class CheckOnboardingStatusUseCase {
  final IOnboardingRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isOnboardingCompleted;
  }
}
