import 'package:money_manager/data/datasources/expense_remote_data_source.dart';
import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Expense>> getExpenses(String tripId) async{
    return await remoteDataSource.getExpenses(tripId);
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
    
        return await remoteDataSource.addExpense(
        tripId: tripId,
        amount: amount,
        date: date,
        participantIds: participantIds,
        payerId: payerId,
        description: description
      );
    
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
    
      return await remoteDataSource.updateExpense(
        tripId: tripId,
        expenseId: expenseId,
        payerId: payerId,
        date: date,
        amount: amount,
        newParticipantIds: newParticipantIds,
        description: description
      );
    
  }

  @override
  Future<void> deleteExpense(
    String tripId, 
    String expenseId
    ) async{
      await remoteDataSource.deleteExpense(tripId, expenseId);
    
  }

  

  
  
}