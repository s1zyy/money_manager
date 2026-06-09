import 'package:dio/dio.dart';
import 'package:money_manager/data/models/expense_model.dart';
import 'package:money_manager/domain/entities/expense.dart';


abstract class ExpenseRemoteDataSource {
  Future<List<Expense>> getExpenses(String tripId);
  Future<Expense> addExpense({
    required String tripId,
    required double amount,
    required DateTime date,
    required List<String> participantIds,
    required String payerId,
    required String description
  });
  Future<Expense> updateExpense({
    required String tripId, 
    required String expenseId, 
    required String payerId, 
    required DateTime date, 
    required double amount, 
    required List<String> newParticipantIds, 
    required String description
  });
  Future<void> deleteExpense(String tripId, String expenseId);
}


class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final Dio dio;

  ExpenseRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Expense>> getExpenses(String tripId) async{
    try{
      final response = await dio.get('/trips/$tripId/expenses');
      final List<dynamic> data = response.data;
      return data.map((json) => ExpenseModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to load expenses');
    }
  }

  @override
  Future<Expense> addExpense({
    required String tripId,
    required double amount,
    required DateTime date,
    required List<String> participantIds,
    required String payerId,
    required String description
  }) async{
    try{
      final body = {
        'payerId': payerId,
        'amount': amount,
        'description': description,
        'date': date.toIso8601String().split('T')[0],
        'participantIds': participantIds,
      };
      final response = await dio.post('/trips/$tripId/expenses', data: body);
      return ExpenseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add expense');
    }
  }

  @override
  Future<Expense> updateExpense({
    required String tripId, 
    required String expenseId, 
    required String payerId, 
    required DateTime date, 
    required double amount, 
    required List<String> newParticipantIds, 
    required String description
  }) async{
    try{
      final body = {
        'payerId': payerId,
        'amount': amount,
        'description': description,
        'date': date.toIso8601String().split('T')[0],
        'participantIds': newParticipantIds,
      };
      final response = await dio.put('/trips/$tripId/expenses/$expenseId', data: body);
      return ExpenseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to update expense');
    }
  }


  @override
  Future<void> deleteExpense(
    String tripId, 
    String expenseId
    ) async{
    try{
      await dio.delete('/trips/$tripId/expenses/$expenseId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete expense');
    }
  }

  
}