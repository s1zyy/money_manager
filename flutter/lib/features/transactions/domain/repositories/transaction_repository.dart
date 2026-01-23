import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<void> createTransaction(Transaction tx);

  Future<void> updateTransaction(Transaction transaction) async {}
  Future<void> sync() async {}
}