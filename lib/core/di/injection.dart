import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/auth/auth_local_data_source.dart';
import '../../data/datasources/local/onboarding_local_data_source.dart';
import '../../data/datasources/remote_cat_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/cat_repository_impl.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_cat_repository.dart';
import '../../domain/repositories/i_onboarding_repository.dart';
import '../../domain/usecases/auth/check_auth_status_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/sign_up_usecase.dart';
import '../../domain/usecases/get_breeds_usecase.dart';
import '../../domain/usecases/get_cats_usecase.dart';
import '../../domain/usecases/onboarding/check_onboarding_status_usecase.dart';
import '../../domain/usecases/onboarding/complete_onboarding_usecase.dart';
import '../../presentation/state/auth_provider.dart';
import '../../presentation/state/breeds_provider.dart';
import '../../presentation/state/cat_provider.dart';
import '../../presentation/state/onboarding_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => CatProvider(getCatsUseCase: sl()));
  sl.registerFactory(() => BreedsProvider(getBreedsUseCase: sl()));
  sl.registerFactory(() => OnboardingProvider(
        checkOnboardingStatusUseCase: sl(),
        completeOnboardingUseCase: sl(),
      ));
  sl.registerFactory(() => AuthProvider(
        checkAuthStatusUseCase: sl(),
        loginUseCase: sl(),
        signUpUseCase: sl(),
        logoutUseCase: sl(),
      ));

  sl.registerLazySingleton(() => GetCatsUseCase(sl()));
  sl.registerLazySingleton(() => GetBreedsUseCase(sl()));

  sl.registerLazySingleton(() => CheckOnboardingStatusUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));

  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));

  sl.registerLazySingleton<ICatRepository>(
    () => CatRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<IOnboardingRepository>(
    () => OnboardingRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<RemoteCatDataSource>(
    () => RemoteCatDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferences: sl(),
    ),
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => http.Client());
}
