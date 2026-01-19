//import 'package:money_manager/core/error/exceptions.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';


class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Transaction>> getTransactions() async {
 
    return await remoteDataSource.getTransactions();
    
    
  }

  @override
  Future<void> createTransaction(Transaction tx) async {
    await remoteDataSource.createTransaction(tx);
  }
}

