import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:money_manager/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'features/transactions/data/datasources/transaction_local_datasource.dart';
import 'features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/domain/repositories/transaction_repository.dart';


final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => http.Client());

  sl.registerLazySingleton(() => TransactionLocalDataSource());
  sl.registerLazySingleton(() => TransactionRemoteDataSource(sl()));

  sl.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl(sl(), sl()));


  sl.registerFactory(() => TransactionBloc(sl()));
}