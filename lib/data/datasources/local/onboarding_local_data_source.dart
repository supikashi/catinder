import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> get isOnboardingCompleted;
  Future<void> completeOnboarding();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _onboardingKey = 'is_onboarding_completed';

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> get isOnboardingCompleted async {
    return sharedPreferences.getBool(_onboardingKey) ?? false;
  }

  @override
  Future<void> completeOnboarding() async {
    await sharedPreferences.setBool(_onboardingKey, true);
  }
}
