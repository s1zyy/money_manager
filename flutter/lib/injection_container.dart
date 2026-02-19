import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:money_manager/core/dio_client.dart';
import 'package:money_manager/data/datasources/auth_local_data_source.dart';
import 'package:money_manager/data/datasources/auth_remote_data_source.dart';
import 'package:money_manager/data/datasources/trip_remote_data_source.dart';
import 'package:money_manager/data/repositories/auth_repository_impl.dart';
import 'package:money_manager/data/repositories/trip_repository_impl.dart';
import 'package:money_manager/domain/repositories/auth_repository.dart';
import 'package:money_manager/domain/repositories/trip_repository.dart';
import 'package:money_manager/domain/usecases/get_user_trips.dart';
import 'package:money_manager/core/auth_interceptor.dart';
import 'package:money_manager/domain/usecases/login.dart';
import 'package:money_manager/domain/usecases/register.dart';
import 'package:money_manager/presentation/providers/auth_provider.dart';
import 'package:money_manager/presentation/providers/trips_provider.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => GetUserTrips(sl())
  );

  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(remoteDataSource: sl()),
    );

  sl.registerLazySingleton<TripRemoteDataSource>(
    () => TripRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton(
    () => TripsProvider(getUserTrips: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl())
  );

  sl.registerLazySingleton(
    () => const FlutterSecureStorage()
  );

  sl.registerLazySingleton(
    () => AuthProvider(loginUseCase: sl(), registerUseCase: sl()),
  );

  sl.registerLazySingleton(
    () => RegisterUseCase(repository: sl())
  );

  sl.registerLazySingleton(
    () => LoginUseCase(repository: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton(
    () => AuthInterceptor(localDataSource: sl()),
  );

  sl.registerLazySingleton<Dio>(() {
    final dio = DioClient().dio;
    dio.interceptors.add(sl<AuthInterceptor>());
    return dio;
  });

}