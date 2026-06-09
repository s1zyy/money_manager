//TODO do expense provider for responding to changes in expenses and update dashboard accordingly 
//TODO do UI for adding and editing expenses

import 'package:flutter/material.dart';
import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/usecases/expenses/add_expense.dart';
import 'package:money_manager/domain/usecases/expenses/delete_expense.dart';
import 'package:money_manager/domain/usecases/expenses/list_expenses.dart';
import 'package:money_manager/domain/usecases/expenses/update_expense.dart';

class ExpensesProvider extends ChangeNotifier { 
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final ListExpensesUseCase listExpensesUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  

  ExpensesProvider({
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.listExpensesUseCase, 
    required this.deleteExpenseUseCase,
  });

  List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadExpenses(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      _expenses = await listExpensesUseCase(tripId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense({
    required String tripId,
    required String payerId,
    required double amount,
    required DateTime date,
    required List<String> participantIds,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      final newExpense = await addExpenseUseCase(
        tripId: tripId,
        payerId: payerId,
        amount: amount,
        date: date,
        participantIds: participantIds,
        description: description,
      );
      _expenses.add(newExpense);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {
    try{
      await deleteExpenseUseCase(tripId: tripId, expenseId: expenseId);
      _expenses.removeWhere((expense) => expense.id == expenseId);
      notifyListeners();
    } catch(e) {
      _errorMessage = e.toString().replaceAll('Exception', '');
      notifyListeners();
    }
  }
}