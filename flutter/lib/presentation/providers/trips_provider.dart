import 'package:flutter/material.dart';
import 'package:money_manager/domain/entities/trip.dart';
import 'package:money_manager/domain/usecases/trip/create_trip.dart';
import 'package:money_manager/domain/usecases/trip/get_user_trips.dart';
import 'package:money_manager/domain/usecases/trip/join_trip_by_code.dart';

class TripsProvider extends ChangeNotifier {
  final GetUserTrips getUserTrips;
  final CreateTripUseCase createTripUseCase;
  final JoinTripByCode joinTripByCodeUseCase;


  TripsProvider({required this.getUserTrips, required this.createTripUseCase, required this.joinTripByCodeUseCase,});

  static const int activeLimit = 10;
  static const int upcomingLimit = 99;

  List<Trip> _trips = [];
  List<Trip> get trips => _trips;
  List<Trip> get activeTrips => _trips.where((t) => t.status == TripStatus.active).toList();
  List<Trip> get upcomingTrips => _trips.where((t) => t.status == TripStatus.upcoming).toList();
  List<Trip> get archivedTrips => _trips.where((t) => t.status == TripStatus.archived).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _joinError;
  String? get joinError => _joinError;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadTrips() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _trips = await getUserTrips();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addTrip({
    required String name,
    required double budget,
    required DateTime startDate,
    required DateTime endDate,
    required String currency,
  }) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final isUpcoming = startDate.isAfter(todayStart);

    if (!isUpcoming && activeTrips.length >= activeLimit) {
      _errorMessage = 'activeLimitReached';
      notifyListeners();
      return false;
    }
    if (isUpcoming && upcomingTrips.length >= upcomingLimit) {
      _errorMessage = 'upcomingLimitReached';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await createTripUseCase(
        name: name,
        budget: budget,
        startDate: startDate,
        endDate: endDate,
        currency: currency,
      );
      await loadTrips();
      return true;
    } catch(e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinTrip(String code, double budget) async {
    _joinError = null;

    try {
      final Trip trip = await joinTripByCodeUseCase(code, budget);
      _trips.add(trip);
      notifyListeners();
      return true;
    } catch (e) {
      _joinError = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }
}