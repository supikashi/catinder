import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection.dart' as di;
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/state/auth_provider.dart';
import 'presentation/state/cat_provider.dart';
import 'presentation/state/breeds_provider.dart';
import 'presentation/state/onboarding_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => di.sl<CatProvider>()..initialize()),
        ChangeNotifierProvider(
            create: (_) => di.sl<BreedsProvider>()..loadBreeds()),
        ChangeNotifierProvider(
            create: (_) => di.sl<OnboardingProvider>()..checkStatus()),
        ChangeNotifierProvider(
            create: (_) => di.sl<AuthProvider>()..checkAuthStatus()),
      ],
      child: MaterialApp(
        title: 'Catinder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AppRoot(),
      ),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<OnboardingProvider, AuthProvider>(
      builder: (context, onboardingProvider, authProvider, _) {
        if (onboardingProvider.isLoading || authProvider.isAuthChecking) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!onboardingProvider.isCompleted) {
          return const OnboardingScreen();
        }

        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        return const MainScreen();
      },
    );
  }
}
