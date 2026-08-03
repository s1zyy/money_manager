import 'package:dio/dio.dart';
import 'package:money_manager/core/dio_error_message.dart';
import 'package:money_manager/data/models/expense_model.dart';
import 'package:money_manager/domain/entities/expense.dart';

abstract class ExpenseRemoteDataSource {
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
    bool isPrepaid = false,
  });
  Future<void> deleteExpense(String tripId, String expenseId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final Dio dio;

  ExpenseRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Expense>> getExpenses(String tripId) async {
    try {
      final response = await dio.get('/trips/$tripId/expenses');
      final List<dynamic> data = response.data;
      return data.map((json) => ExpenseModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
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
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'splitMode': splitMode,
        'description': description,
        'isPrepaid': isPrepaid,
      };
      if (date != null) body['date'] = date.toIso8601String().split('T')[0];
      if (payerId != null) body['payerId'] = payerId;
      if (splitMode == 'EQUAL') {
        body['participantIds'] = participantIds;
      } else {
        body['customShares'] = customShares;
      }
      await dio.post('/trips/$tripId/expenses', data: body);
      return true;
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<Expense> updateExpense({
    required String tripId,
    required String expenseId,
    required DateTime date,
    required double amount,
    required String splitMode,
    List<String>? newParticipantIds,
    Map<String, double>? customShares,
    required String description,
    bool isPrepaid = false,
  }) async {
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'date': date.toIso8601String().split('T')[0],
        'splitMode': splitMode,
        'description': description,
        'isPrepaid': isPrepaid,
      };
      if (splitMode == 'EQUAL') {
        body['newParticipantIds'] = newParticipantIds;
      } else {
        body['customShares'] = customShares;
      }
      final response = await dio.put('/trips/$tripId/expenses/$expenseId', data: body);
      return ExpenseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }

  @override
  Future<void> deleteExpense(String tripId, String expenseId) async {
    try {
      await dio.delete('/trips/$tripId/expenses/$expenseId');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e));
    }
  }
}
