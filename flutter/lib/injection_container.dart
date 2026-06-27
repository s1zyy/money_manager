import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_manager/core/dio_client.dart';
import 'package:money_manager/data/datasources/auth_local_data_source.dart';
import 'package:money_manager/data/datasources/auth_remote_data_source.dart';
import 'package:money_manager/data/datasources/expense_remote_data_source.dart';
import 'package:money_manager/data/datasources/participant_remote_data_source.dart';
import 'package:money_manager/data/datasources/trip_remote_data_source.dart';
import 'package:money_manager/data/repositories/auth_repository_impl.dart';
import 'package:money_manager/data/repositories/expense_repository_impl.dart';
import 'package:money_manager/data/repositories/participant_repository_impl.dart';
import 'package:money_manager/data/repositories/trip_repository_impl.dart';
import 'package:money_manager/domain/repositories/auth_repository.dart';
import 'package:money_manager/domain/repositories/expense_repository.dart';
import 'package:money_manager/domain/repositories/participant_repository.dart';
import 'package:money_manager/domain/repositories/trip_repository.dart';
import 'package:money_manager/domain/usecases/auth/check_auth.dart';
import 'package:money_manager/domain/usecases/auth/logout.dart';
import 'package:money_manager/domain/usecases/expenses/add_expense.dart';
import 'package:money_manager/domain/usecases/expenses/delete_expense.dart';
import 'package:money_manager/domain/usecases/expenses/get_trip_dashboard.dart';
import 'package:money_manager/domain/usecases/expenses/list_expenses.dart';
import 'package:money_manager/domain/usecases/expenses/update_expense.dart';
import 'package:money_manager/domain/usecases/participant/get_participants_map.dart';
import 'package:money_manager/domain/usecases/trip/add_virtual_participant.dart';
import 'package:money_manager/domain/usecases/trip/archive_trip.dart';
import 'package:money_manager/domain/usecases/trip/create_trip.dart';
import 'package:money_manager/domain/usecases/trip/delete_trip.dart';
import 'package:money_manager/domain/usecases/trip/get_user_trips.dart';
import 'package:money_manager/core/auth_interceptor.dart';
import 'package:money_manager/domain/usecases/trip/join_trip_by_code.dart';
import 'package:money_manager/domain/usecases/auth/login.dart';
import 'package:money_manager/domain/usecases/auth/register.dart';
import 'package:money_manager/domain/usecases/trip/leave_trip.dart';
import 'package:money_manager/domain/usecases/trip/remove_participant.dart';
import 'package:money_manager/domain/usecases/trip/update_trip.dart';
import 'package:money_manager/presentation/pages/login_page.dart';
import 'package:money_manager/presentation/providers/auth_provider.dart';
import 'package:money_manager/presentation/providers/locale_provider.dart';
import 'package:money_manager/presentation/providers/trip_dashboard_provider.dart';
import 'package:money_manager/presentation/providers/trips_provider.dart';

final sl = GetIt.instance;

Future<void> init({required GlobalKey<NavigatorState> navigatorKey}) async {
  sl.registerLazySingleton(() => GetUserTrips(sl())
  );
  //Trip

  sl.registerLazySingleton(
    () => CreateTripUseCase(tripRepository: sl()),
  );

  sl.registerLazySingleton<TripRepository>(
    () => TripRepositoryImpl(remoteDataSource: sl()),
    );

  sl.registerLazySingleton<TripRemoteDataSource>(
    () => TripRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerFactory(
    () => JoinTripByCode(repository: sl()),
  );

  sl.registerLazySingleton(
    () => TripsProvider(getUserTrips: sl(), createTripUseCase: sl(), joinTripByCodeUseCase: sl()),
  );

  sl.registerLazySingleton(
    () => GetTripDashboardUseCase(repository: sl()),
  );

  //----

  //Expense

  sl.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton(
    () => AddExpenseUseCase(repository: sl()),
  );

  sl.registerLazySingleton(
    () => UpdateExpenseUseCase(repository: sl()),
  );

  sl.registerLazySingleton(
    () => DeleteExpenseUseCase(repository: sl()),
  );

  sl.registerLazySingleton(
    () => ListExpensesUseCase(repository: sl()),
  );

  sl.registerLazySingleton(
    () => UpdateTripUseCase(repository: sl()),
  );

  sl.registerLazySingleton(
    () => ArchiveTripUseCase(repository: sl()),
  );

  sl.registerLazySingleton(
    () => LeaveTripUseCase(repository: sl()),
  );

  sl.registerLazySingleton(
    () => RemoveParticipantUseCase(repository: sl()),
  );
  
  sl.registerLazySingleton(
    () => DeleteTripUseCase(repository: sl()),
  );
  
  sl.registerLazySingleton(
    () => AddVirtualParticipantUseCase(repository: sl()),
  );


  sl.registerFactory(
    () => TripDashboardProvider(
      addExpenseUseCase: sl(),
      deleteExpenseUseCase: sl(),
      getTripDashboardUseCase: sl(),
      updateExpenseUseCase: sl(),
      getParticipantsMapUseCase: sl(),
      updateTripUseCase: sl(),
      archiveTripUseCase: sl(),
      leaveTripUseCase: sl(),
      deleteTripUseCase: sl(),
      removeParticipantUseCase: sl(),
      addVirtualParticipantUseCase: sl(),
      ),
      
  );

  //-------


  //Participant

  sl.registerLazySingleton<ParticipantRemoteDataSource>(
    () => ParticipantRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<ParticipantRepository>(
    () => ParticipantRepositoryImpl(participantRemoteDataSource: sl()),
  );

  sl.registerLazySingleton(
    () => GetParticipantsMapUseCase(repository: sl()),
  );

  //-----

  //Auth + login

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(secureStorage: sl())
  );

  

  sl.registerLazySingleton(
    () => AuthProvider(loginUseCase: sl(), registerUseCase: sl(), logoutUseCase: sl()),
  );

  sl.registerLazySingleton(
    () => RegisterUseCase(repository: sl())
  );

  sl.registerLazySingleton(
    () => LoginUseCase(repository: sl()),
  );

  sl.registerLazySingleton(
    () => LogoutUseCase(repository: sl()),
  );

  sl.registerLazySingleton(
    () => CheckAuthUseCase(repository: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton(
    () => AuthInterceptor(localDataSource: sl(), onUnauthorized: () {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }),
  );

  //-----

  sl.registerLazySingleton(
    () => const FlutterSecureStorage()
  );

  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);
  sl.registerLazySingleton(() => LocaleProvider(prefs));

  sl.registerLazySingleton(() => DioClient());

  sl.registerLazySingleton<Dio>(() {

    final dio = sl<DioClient>().dio;
    
    dio.interceptors.add(sl<AuthInterceptor>());

    dio.interceptors.add(LogInterceptor(requestBody: false, responseBody: true));
    return dio;
  });

}