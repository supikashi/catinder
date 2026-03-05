import '../../repositories/i_onboarding_repository.dart';

class CompleteOnboardingUseCase {
  final IOnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  Future<void> call() async {
    await repository.completeOnboarding();
  }
}
