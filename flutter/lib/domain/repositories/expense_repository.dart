import 'package:money_manager/domain/entities/expense.dart';

abstract class ExpenseRepository {
  Future<List<Expense>> getExpenses(String tripId);

  Future<bool> addExpense({
    required String tripId,
    required double amount,
    DateTime? date,
    required String splitMode,
    String? payerId,
    List<String>? participantIds,
    Map<String, double>? customShares,
    required String description,
    bool isPrepaid = false,
  });

  Future<Expense> updateExpense({
    required String tripId,
    required String expenseId,
    required DateTime date,
    required double amount,
    required String splitMode,
    List<String>? newParticipantIds,
    Map<String, double>? customShares,
    required String description,
  });

  Future<void> deleteExpense(String tripId, String expenseId);
}
