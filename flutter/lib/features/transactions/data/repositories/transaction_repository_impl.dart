//import 'package:money_manager/core/error/exceptions.dart';

import 'package:money_manager/features/transactions/data/datasources/transaction_remote_datasource.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl(
    this.localDataSource,
    this.remoteDataSource,);

  @override
  Future<List<Transaction>> getTransactions() async {
    final localTransactions = await localDataSource.getTransactions();
    
    try {
      final remoteTransactions = await remoteDataSource.getTransactions();


      for(final tx in remoteTransactions) {
        await localDataSource.createTransaction(tx);
      }
      return remoteTransactions;

    } catch (_) {
      return localTransactions;
    }
  }

  @override
  Future<void> createTransaction(Transaction tx) async {
    await localDataSource.createTransaction(tx);
  }
}

