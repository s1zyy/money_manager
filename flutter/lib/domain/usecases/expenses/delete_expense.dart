import 'package:money_manager/domain/repositories/expense_repository.dart';

class DeleteExpenseUseCase {

  final ExpenseRepository repository;
  DeleteExpenseUseCase({required this.repository});

  Future<void> call({
    required String tripId,
    required String expenseId,
  }) async {
    await repository.deleteExpense(tripId, expenseId);
  }
}