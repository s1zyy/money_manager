

import 'package:flutter/material.dart';
import 'package:money_manager/domain/entities/dashboard_participant.dart';
import 'package:money_manager/domain/entities/expense.dart';
import 'package:money_manager/domain/entities/participant_info.dart';
import 'package:money_manager/domain/entities/settlement_transfer.dart';
import 'package:money_manager/domain/entities/trip_dashboard.dart';
import 'package:money_manager/domain/usecases/expenses/add_expense.dart';
import 'package:money_manager/domain/usecases/expenses/delete_expense.dart';
import 'package:money_manager/domain/usecases/expenses/get_trip_dashboard.dart';
import 'package:money_manager/domain/usecases/expenses/update_expense.dart';
import 'package:money_manager/domain/usecases/participant/get_participants_map.dart';
import 'package:money_manager/domain/usecases/trip/add_virtual_participant.dart';
import 'package:money_manager/domain/usecases/trip/archive_trip.dart';
import 'package:money_manager/domain/usecases/trip/delete_trip.dart';
import 'package:money_manager/domain/usecases/trip/get_trip_settlement.dart';
import 'package:money_manager/domain/usecases/trip/unarchive_trip.dart';
import 'package:money_manager/domain/usecases/trip/leave_trip.dart';
import 'package:money_manager/domain/usecases/trip/remove_participant.dart';
import 'package:money_manager/domain/usecases/trip/update_trip.dart';

class TripDashboardProvider extends ChangeNotifier {
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final GetTripDashboardUseCase getTripDashboardUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final GetParticipantsMapUseCase getParticipantsMapUseCase;
  final UpdateTripUseCase updateTripUseCase;
  final ArchiveTripUseCase archiveTripUseCase;
  final LeaveTripUseCase leaveTripUseCase;
  final DeleteTripUseCase deleteTripUseCase;
  final RemoveParticipantUseCase removeParticipantUseCase;
  final AddVirtualParticipantUseCase addVirtualParticipantUseCase;
  final GetTripSettlementUseCase getTripSettlementUseCase;
  final UnarchiveTripUseCase unarchiveTripUseCase;

  TripDashboardProvider({
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.getTripDashboardUseCase,
    required this.deleteExpenseUseCase,
    required this.getParticipantsMapUseCase,
    required this.updateTripUseCase,
    required this.archiveTripUseCase,
    required this.leaveTripUseCase,
    required this.deleteTripUseCase,
    required this.removeParticipantUseCase,
    required this.addVirtualParticipantUseCase,
    required this.getTripSettlementUseCase,
    required this.unarchiveTripUseCase,
  });

  TripDashboard? _dashboard;
  TripDashboard? get dashboard => _dashboard;

  List<SettlementTransfer>? _settlement;
  List<SettlementTransfer>? get settlement => _settlement;

  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _dashboard?.expenses ?? [];
  List<DashboardParticipant> get participants => _dashboard?.participants ?? [];

  Map<String, ParticipantInfo> _participantsMap = {};

  Map<String, ParticipantInfo> get participantsMap => _participantsMap;



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
      final participants = results[1] as List<ParticipantInfo>;
      _dashboard = results[0] as TripDashboard;
      _participantsMap = {for (var p in participants) p.id: p};

    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  String getParticipantName(String id) => _participantsMap[id]?.name ?? "Unknown";
  bool isVirtualParticipant(String id) => _participantsMap[id]?.isVirtual ?? false;

  Future<bool> addExpense({
    required String tripId,
    required double amount,
    required DateTime date,
    required String splitMode,
    String? payerId,
    List<String>? participantIds,
    Map<String, double>? customShares,
    required String description,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await addExpenseUseCase(
        tripId: tripId,
        amount: amount,
        date: date,
        splitMode: splitMode,
        payerId: payerId,
        participantIds: participantIds,
        customShares: customShares,
        description: description,
      );
      await loadDashboard(tripId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String tripId, String expenseId) async {

    if (_dashboard == null) return;


  final tempExpenses = List<Expense>.from(_dashboard!.expenses)
    ..removeWhere((e) => e.id == expenseId);

  _dashboard = TripDashboard(
    trip: _dashboard!.trip,
    dailyLimit: _dashboard!.dailyLimit,
    participants: _dashboard!.participants,
    expenses: tempExpenses,
    isOwner: _dashboard!.isOwner,
    canLeave: _dashboard!.canLeave
  );
  
  notifyListeners();

    try{
      await deleteExpenseUseCase(tripId: tripId, expenseId: expenseId);
      await loadDashboard(tripId);
    } catch(e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> updateTrip({
    required String tripId,
    required String name,
    required double totalBudget,
    required double prepaidExpenses,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try{
      await updateTripUseCase(
        tripId: tripId,
        name: name,
        totalBudget: totalBudget,
        prepaidExpenses: prepaidExpenses,
        currency: currency,
        startDate: startDate,
        endDate: endDate,
      );
      await loadDashboard(tripId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> archiveTrip(String tripId) async{
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await archiveTripUseCase(tripId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
  }

  Future<bool> leaveTrip(String tripId) async{
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await leaveTripUseCase(tripId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
  }
  Future<bool> deleteTrip(String tripId) async{
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await deleteTripUseCase(tripId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    
  }


  Future<bool> removeParticipant(String tripId, String participantId) async {
    try {
      await removeParticipantUseCase(tripId, participantId);
      await loadDashboard(tripId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> unarchiveTrip(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await unarchiveTripUseCase(tripId);
      await loadDashboard(tripId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadSettlement(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _settlement = await getTripSettlementUseCase(tripId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addVirtualParticipant(String tripId, String name) async {
    try {
      await addVirtualParticipantUseCase(tripId, name);
      await loadDashboard(tripId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Map<DateTime, List<Expense>> get expensesByDay {
    final map = <DateTime, List<Expense>>{};
    for (final expense in expenses) {
      final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
      map.putIfAbsent(day, () => []).add(expense);
    }
    final sorted = Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
    return sorted;
  }

  double get todaySpent {
    if(_dashboard == null || _dashboard!.expenses.isEmpty) return 0.0;

    final today = DateTime.now();

    return _dashboard!.expenses
      .where((expense) =>
        expense.date.year == today.year &&
        expense.date.month == today.month &&
        expense.date.day == today.day)
        .map((expense) => expense.amount)
        .fold(0.0, (sum, amount) => sum + amount);
  }

  double get limitProgress {
    final limit = _dashboard?.dailyLimit ?? 0.0;
    if(limit == 0.0) return 0.0;
    final progress = todaySpent / limit;
    return progress > 1.0 ? 1.0 : progress;

  }
}