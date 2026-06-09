import 'package:money_manager/domain/entities/expense.dart';

abstract class ExpenseRepository {

  Future<List<Expense>> getExpenses(String tripId);


  Future<Expense> addExpense({
    required String tripId,
    required double amount,
    required DateTime date,
    required List<String> participantIds,
    required String payerId,
    required String description,
  });


  Future<Expense> updateExpense({
    required String tripId,
    required String expenseId,
    required String payerId,
    required DateTime date,
    required double amount, 
    required List<String> newParticipantIds,
    required String description,
  });

  Future<void> deleteExpense(String tripId, String expenseId);


}