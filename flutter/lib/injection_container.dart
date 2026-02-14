import 'package:get_it/get_it.dart';
import 'package:money_manager/core/dio_client.dart';
import 'package:money_manager/data/datasources/trip_remote_data_source.dart';
import 'package:money_manager/data/repositories/trip_repository_impl.dart';
import 'package:money_manager/domain/repositories/trip_repository.dart';
import 'package:money_manager/domain/usecases/getUserTrips.dart';


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

  sl.registerLazySingleton(() => DioClient().dio);


}