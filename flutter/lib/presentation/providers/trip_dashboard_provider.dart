

import 'package:flutter/material.dart';
import 'package:money_manager/domain/entities/dashboard_participant.dart';
import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/entities/trip_dashboard.dart';
import 'package:money_manager/domain/usecases/expenses/add_expense.dart';
import 'package:money_manager/domain/usecases/expenses/delete_expense.dart';
import 'package:money_manager/domain/usecases/expenses/get_trip_dashboard.dart';
import 'package:money_manager/domain/usecases/expenses/update_expense.dart';
import 'package:money_manager/domain/usecases/participant/get_participants_map.dart';

class TripDashboardProvider extends ChangeNotifier { 
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final GetTripDashboardUseCase getTripDashboardUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final GetParticipantsMapUseCase getParticipantsMapUseCase;
  

  TripDashboardProvider({
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.getTripDashboardUseCase, 
    required this.deleteExpenseUseCase,
    required this.getParticipantsMapUseCase,
  });

  TripDashboard? _dashboard;
  TripDashboard? get dashboard => _dashboard;

  // List<Expense> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // List<Expense> get expenses => _expenses;
  List<Expense> get expenses => _dashboard?.expenses ?? [];
  List<DashboardParticipant> get participants => _dashboard?.participants ?? [];

  Map<String, String> _participantsMap = {};

  Map<String, String> get participantsMap => _participantsMap;



  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      final results = await Future.wait([
        getTripDashboardUseCase(tripId),
        getParticipantsMapUseCase(tripId)
      ]);
      _dashboard = results[0] as TripDashboard;
      _participantsMap = results[1] as Map<String, String>;

    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  String getParticipantName(String id) => _participantsMap[id] ?? "Unknown";

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
      await addExpenseUseCase(
        tripId: tripId,
        payerId: payerId,
        amount: amount,
        date: date,
        participantIds: participantIds,
        description: description,
      );
      await loadDashboard(tripId);
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
      await loadDashboard(tripId);
      notifyListeners();
    } catch(e) {
      _errorMessage = e.toString().replaceAll('Exception', '');
      notifyListeners();
    }
  }
}