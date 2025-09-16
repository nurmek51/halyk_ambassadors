import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/auth_interceptor.dart';
import 'core/services/auth_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/profile_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/request_otp.dart';
import 'features/auth/domain/usecases/verify_otp.dart';
import 'features/auth/domain/usecases/create_profile.dart';
import 'features/auth/domain/usecases/refresh_token.dart';
import 'features/auth/domain/usecases/check_user_profile.dart';
import 'features/auth/domain/usecases/get_profile_me.dart';
import 'features/auth/domain/usecases/update_profile.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Application imports
import 'features/applications/data/datasources/application_remote_datasource.dart';
import 'features/applications/data/repositories/application_repository_impl.dart';
import 'features/applications/domain/repositories/application_repository.dart';
import 'features/applications/domain/usecases/create_application.dart';
import 'features/applications/domain/usecases/get_user_applications.dart';
import 'features/applications/domain/usecases/geocode_address.dart';
import 'features/applications/domain/usecases/get_geolocation_address.dart';
import 'features/applications/presentation/bloc/application_bloc.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Load environment variables with error handling
  String apiBaseUrl = 'http://localhost:8000'; // Default fallback

  try {
    await dotenv.load(fileName: '.env');
    apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000';
  } catch (e) {
    // Using default localhost:8000 configuration
  }

  // External
  final sharedPreferences = await SharedPreferences.getInstance();

  sl.registerLazySingleton(() => sharedPreferences);

  // Auth Service
  sl.registerLazySingleton(() => AuthService(sl()));

  // Dio
  final dio = Dio();
  dio.options.baseUrl = apiBaseUrl;
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  // Add auth interceptor
  dio.interceptors.add(
    AuthInterceptor(
      sharedPreferences: sharedPreferences,
      authService: sl(),
      dio: dio,
    ),
  );

  // Add logging interceptor for debugging
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ),
  );

  sl.registerLazySingleton(() => dio);

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      profileRemoteDataSource: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => RequestOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => CreateProfile(sl()));
  sl.registerLazySingleton(() => GetCities(sl()));
  sl.registerLazySingleton(() => RefreshToken(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => CheckUserProfile(sl()));
  sl.registerLazySingleton(() => GetProfileMeUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));

  // Application Data Sources
  sl.registerLazySingleton<ApplicationRemoteDataSource>(
    () => ApplicationRemoteDataSourceImpl(dio: sl()),
  );

  // Application Repositories
  sl.registerLazySingleton<ApplicationRepository>(
    () => ApplicationRepositoryImpl(remoteDataSource: sl()),
  );

  // Application Use Cases
  sl.registerLazySingleton(() => CreateApplication(sl()));
  sl.registerLazySingleton(() => GetUserApplications(sl()));
  sl.registerLazySingleton(() => GeocodeAddress(sl()));
  sl.registerLazySingleton(() => GetGeolocationAddress(sl()));

  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      requestOtp: sl(),
      verifyOtp: sl(),
      createProfile: sl(),
      getCities: sl(),
      refreshToken: sl(),
      checkAuthStatus: sl(),
      checkUserProfile: sl(),
      getProfileMe: sl(),
      updateProfile: sl(),
    ),
  );

  sl.registerFactory(
    () => ApplicationBloc(
      createApplication: sl(),
      getUserApplications: sl(),
      geocodeAddress: sl(),
      getGeolocationAddress: sl(),
      authBloc: sl(),
      updateProfile: sl(),
    ),
  );
}
