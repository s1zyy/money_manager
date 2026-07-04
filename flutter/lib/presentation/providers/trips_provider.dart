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

  List<Trip> _trips = [];
  List<Trip> get trips => _trips;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Trip trip = await joinTripByCodeUseCase(code, budget);
      
      _trips.add(trip);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}