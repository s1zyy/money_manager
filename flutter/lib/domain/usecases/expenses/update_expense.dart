import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/repositories/expense_repository.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase({required this.repository});

  Future<Expense> call({
    required String tripId,
    required String expenseId,
    required String payerId,
    required DateTime date,
    required double amount,
    required List<String> newParticipantIds,
    required String description,
  }) async {
    return await repository.updateExpense(
      tripId: tripId,
      expenseId: expenseId,
      payerId: payerId,
      date: date,
      amount: amount,
      newParticipantIds: newParticipantIds,
      description: description,
    );
  }
}