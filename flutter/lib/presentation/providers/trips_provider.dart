import 'package:flutter/material.dart';
import 'package:money_manager/domain/entities/trip.dart';
import 'package:money_manager/domain/usecases/get_user_trips.dart';

class TripsProvider extends ChangeNotifier {
  final GetUserTrips getUserTrips;

  TripsProvider({required this.getUserTrips});

  List<Trip> _trips = [];
  List<Trip> get trips => _trips;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();
    try {
      _trips = await getUserTrips();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}