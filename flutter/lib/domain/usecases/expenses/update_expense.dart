import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/repositories/expense_repository.dart';

class UpdateExpenseUseCase {
  final ExpenseRepository repository;

  UpdateExpenseUseCase({required this.repository});

  Future<Expense> call({
    required String tripId,
    required String expenseId,
    required DateTime date,
    required double amount,
    required String splitMode,
    List<String>? newParticipantIds,
    Map<String, double>? customShares,
    required String description,
  }) async {
    return await repository.updateExpense(
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
}
