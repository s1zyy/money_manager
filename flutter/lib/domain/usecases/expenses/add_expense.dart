import 'package:money_manager/domain/repositories/expense_repository.dart';

class AddExpenseUseCase {
  final ExpenseRepository repository;
  AddExpenseUseCase({required this.repository});

  Future<bool> call({
    required String tripId,
    required double amount,
    DateTime? date,
    required String splitMode,
    String? payerId,
    List<String>? participantIds,
    Map<String, double>? customShares,
    required String description,
    bool isPrepaid = false,
  }) async {
    return await repository.addExpense(
      tripId: tripId,
      amount: amount,
      date: date,
      splitMode: splitMode,
      payerId: payerId,
      participantIds: participantIds,
      customShares: customShares,
      description: description,
      isPrepaid: isPrepaid,
    );
  }
}
