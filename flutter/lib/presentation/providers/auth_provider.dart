import 'package:flutter/foundation.dart';
import 'package:money_manager/domain/usecases/login.dart';
import 'package:money_manager/domain/usecases/register.dart';
class AuthProvider extends ChangeNotifier{
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  AuthProvider({required this.loginUseCase, required this.registerUseCase});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await loginUseCase.call(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }

  }

  Future<bool> register(String email, String password, String name) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await registerUseCase.call(email, password, name);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
      
  }
}