import 'package:money_manager/domain/repositories/expense_repository.dart';

class AddExpenseUseCase {

  final ExpenseRepository repository;
  AddExpenseUseCase({required this.repository});

  Future<bool> call({
    required String tripId,
    required String payerId,
    required double amount,
    required DateTime date,
    required List<String> participantIds,
    required String description,
  }) async {
    return await repository.addExpense(
      tripId: tripId,
      payerId: payerId,
      amount: amount,
      date: date,
      participantIds: participantIds,
      description: description,
    );
  }
}