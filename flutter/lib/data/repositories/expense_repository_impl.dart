import 'package:money_manager/data/datasources/expense_remote_data_source.dart';
import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Expense>> getExpenses(String tripId) async {
    return await remoteDataSource.getExpenses(tripId);
  }

  @override
  Future<bool> addExpense({
    required String tripId,
    required double amount,
    required DateTime date,
    required String splitMode,
    String? payerId,
    List<String>? participantIds,
    Map<String, double>? customShares,
    required String description,
  }) async {
    return await remoteDataSource.addExpense(
      tripId: tripId,
      amount: amount,
      date: date,
      splitMode: splitMode,
      payerId: payerId,
      participantIds: participantIds,
      customShares: customShares,
      description: description,
    );
  }

  @override
  Future<Expense> updateExpense({
    required String tripId,
    required String expenseId,
    required DateTime date,
    required double amount,
    required String splitMode,
    List<String>? newParticipantIds,
    Map<String, double>? customShares,
    required String description,
  }) async {
    return await remoteDataSource.updateExpense(
      tripId: tripId,
      expenseId: expenseId,
      date: date,
      amount: amount,
      splitMode: splitMode,
      newParticipantIds: newParticipantIds,
      customShares: customShares,
      description: description,
    );
  }

  @override
  Future<void> deleteExpense(String tripId, String expenseId) async {
    await remoteDataSource.deleteExpense(tripId, expenseId);
  }
}
