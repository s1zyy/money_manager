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
import 'package:money_manager/domain/usecases/trip/update_my_budget.dart';
import 'package:money_manager/domain/usecases/trip/update_participant_budget.dart';
import 'package:money_manager/domain/usecases/trip/invite_virtual_participant.dart';

class TripDashboardProvider extends ChangeNotifier {
  final AddExpenseUseCase addExpenseUseCase;
  final UpdateExpenseUseCase updateExpenseUseCase;
  final GetTripDashboardUseCase getTripDashboardUseCase;
  final DeleteExpenseUseCase deleteExpenseUseCase;
  final GetParticipantsMapUseCase getParticipantsMapUseCase;
  final UpdateTripUseCase updateTripUseCase;
  final UpdateMyBudgetUseCase updateMyBudgetUseCase;
  final UpdateParticipantBudgetUseCase updateParticipantBudgetUseCase;
  final ArchiveTripUseCase archiveTripUseCase;
  final LeaveTripUseCase leaveTripUseCase;
  final DeleteTripUseCase deleteTripUseCase;
  final RemoveParticipantUseCase removeParticipantUseCase;
  final AddVirtualParticipantUseCase addVirtualParticipantUseCase;
  final InviteVirtualParticipantUseCase inviteVirtualParticipantUseCase;
  final GetTripSettlementUseCase getTripSettlementUseCase;
  final UnarchiveTripUseCase unarchiveTripUseCase;

  TripDashboardProvider({
    required this.addExpenseUseCase,
    required this.updateExpenseUseCase,
    required this.getTripDashboardUseCase,
    required this.deleteExpenseUseCase,
    required this.getParticipantsMapUseCase,
    required this.updateTripUseCase,
    required this.updateMyBudgetUseCase,
    required this.updateParticipantBudgetUseCase,
    required this.archiveTripUseCase,
    required this.leaveTripUseCase,
    required this.deleteTripUseCase,
    required this.removeParticipantUseCase,
    required this.addVirtualParticipantUseCase,
    required this.getTripSettlementUseCase,
    required this.unarchiveTripUseCase,
    required this.inviteVirtualParticipantUseCase,
  });

  TripDashboard? _dashboard;
  TripDashboard? get dashboard => _dashboard;

  List<SettlementTransfer>? _settlement;
  List<SettlementTransfer>? get settlement => _settlement;

  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => _dashboard?.expenses ?? [];
  List<DashboardParticipant> get participants => _dashboard?.participants ?? [];
  double get myBudget => _dashboard?.myStats.budget ?? 0.0;
  double get myDailyLimit => _dashboard?.myStats.dailyLimit ?? 0.0;
  double get todaySpent => _dashboard?.myStats.spentToday ?? 0.0;
  String? get myParticipantId => _dashboard?.myStats.participantId;

  double myShareOf(Expense e) =>
      _dashboard?.myStats.shareOf(e.amount, e.participantShares, e.splitMode) ?? 0.0;

  List<Expense> get regularExpenses =>
      expenses.where((e) => !e.isPrepaid).toList();

  List<Expense> get prepaidExpenses =>
      expenses.where((e) => e.isPrepaid).toList();

  Map<String, ParticipantInfo> _participantsMap = {};
  Map<String, ParticipantInfo> get participantsMap => _participantsMap;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadDashboard(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        getTripDashboardUseCase(tripId),
        getParticipantsMapUseCase(tripId),
      ]);
      final participantsList = results[1] as List<ParticipantInfo>;
      _dashboard = results[0] as TripDashboard;
      _participantsMap = {for (var p in participantsList) p.id: p};
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String getParticipantName(String id) => _participantsMap[id]?.name ?? 'Unknown';
  bool isVirtualParticipant(String id) => _participantsMap[id]?.isVirtual ?? false;
  String? getParticipantAvatarUrl(String id) => _participantsMap[id]?.avatarUrl;

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
        isPrepaid: isPrepaid,
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

  Future<bool> updateExpense({
    required String tripId,
    required String expenseId,
    required double amount,
    DateTime? date,
    required String splitMode,
    String? payerId,
    List<String>? participantIds,
    Map<String, double>? customShares,
    required String description,
    bool isPrepaid = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await updateExpenseUseCase(
        tripId: tripId,
        expenseId: expenseId,
        amount: amount,
        date: date ?? DateTime.now(),
        splitMode: splitMode,
        newParticipantIds: participantIds,
        customShares: customShares,
        description: description,
        isPrepaid: isPrepaid,
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
      myStats: _dashboard!.myStats,
      participants: _dashboard!.participants,
      expenses: tempExpenses,
      isOwner: _dashboard!.isOwner,
      canLeave: _dashboard!.canLeave,
    );
    notifyListeners();

    try {
      await deleteExpenseUseCase(tripId: tripId, expenseId: expenseId);
      await loadDashboard(tripId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<bool> updateTrip({
    required String tripId,
    required String name,
    required String currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await updateTripUseCase(
        tripId: tripId,
        name: name,
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

  Future<bool> updateMyBudget({
    required String tripId,
    required double budget,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await updateMyBudgetUseCase(tripId: tripId, budget: budget);
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

  Future<bool> updateParticipantBudget({
    required String tripId,
    required String participantId,
    required double budget,
  }) async {
    try {
      await updateParticipantBudgetUseCase(
          tripId: tripId, participantId: participantId, budget: budget);
      await loadDashboard(tripId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> archiveTrip(String tripId) async {
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

  Future<bool> leaveTrip(String tripId) async {
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

  Future<bool> deleteTrip(String tripId) async {
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

  Future<bool> addVirtualParticipant(
      String tripId, String name, double budget) async {
    try {
      await addVirtualParticipantUseCase(tripId, name, budget);
      await loadDashboard(tripId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> inviteVirtualParticipant(String tripId, String participantId, String email, {bool force = false}) async {
    try {
      await inviteVirtualParticipantUseCase(tripId, participantId, email, force: force);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Map<DateTime, List<Expense>> get expensesByDay {
    final map = <DateTime, List<Expense>>{};
    for (final expense in regularExpenses) {
      final day = DateTime(
          expense.date!.year, expense.date!.month, expense.date!.day);
      map.putIfAbsent(day, () => []).add(expense);
    }
    return Map.fromEntries(
      map.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  double get limitProgress {
    final limit = myDailyLimit;
    if (limit <= 0.0) return 0.0;
    final progress = todaySpent / limit;
    return progress > 1.0 ? 1.0 : progress;
  }
}
