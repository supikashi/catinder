abstract class IOnboardingRepository {
  Future<bool> get isOnboardingCompleted;
  Future<void> completeOnboarding();
}
