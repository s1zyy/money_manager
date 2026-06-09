import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/repositories/expense_repository.dart';

class ListExpensesUseCase {
  final ExpenseRepository repository;
  ListExpensesUseCase({required this.repository});

  Future<List<Expense>> call(String tripId) async {
    return await repository.getExpenses(tripId);
  }
}