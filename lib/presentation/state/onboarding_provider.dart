import 'package:flutter/material.dart';
import '../../domain/usecases/onboarding/check_onboarding_status_usecase.dart';
import '../../domain/usecases/onboarding/complete_onboarding_usecase.dart';

class OnboardingProvider extends ChangeNotifier {
  final CheckOnboardingStatusUseCase checkOnboardingStatusUseCase;
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  bool _isCompleted = false;
  bool get isCompleted => _isCompleted;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  OnboardingProvider({
    required this.checkOnboardingStatusUseCase,
    required this.completeOnboardingUseCase,
  });

  Future<void> checkStatus() async {
    _isLoading = true;
    notifyListeners();

    _isCompleted = await checkOnboardingStatusUseCase();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await completeOnboardingUseCase();
    _isCompleted = true;
    notifyListeners();
  }
}
