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
    try {
      await sync();
    }catch(e){
      print("Push failed: $e");
    }
    try {
      final remoteTransactions = await remoteDataSource.getTransactions();
      for(final tx in remoteTransactions) {
        await localDataSource.upsertTransaction(tx);
      }
    } catch (e) {
      print('Fetch failed: $e');
    }
    return localDataSource.getTransactions();
  }

  @override
  Future<void> createTransaction(Transaction tx) async {
    await localDataSource.createTransaction(tx);

    try{
      await sync();
    } catch(e){
      print("Push failed: $e");
    }
  }

  Future<void> sync() async {
    final unsynced = await localDataSource.getUnsyncedTransactions();

    for (final tx in unsynced) {
      try {
        await remoteDataSource.createTransaction(tx);
        await localDataSource.markAsSynced(tx.id);
      } catch (_) {
        
      }
    }
  }
}

