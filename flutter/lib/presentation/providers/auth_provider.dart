import 'package:flutter/foundation.dart';
import 'package:money_manager/domain/usecases/auth/login.dart';
import 'package:money_manager/domain/usecases/auth/logout.dart';
import 'package:money_manager/domain/usecases/auth/register.dart';
import 'package:money_manager/domain/usecases/auth/validate_invite_token.dart';

String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final ValidateInviteTokenUseCase validateInviteTokenUseCase;

  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.validateInviteTokenUseCase,
  });

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isValidatingToken = false;
  bool get isValidatingToken => _isValidatingToken;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentUserEmail;
  String? _currentUserName;
  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserName => _currentUserName;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await loginUseCase.call(email, password);
      _currentUserEmail = email;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _clean(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, {String? inviteToken}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await registerUseCase.call(email, password, name, inviteToken: inviteToken);
      _currentUserEmail = email;
      _currentUserName = name;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _clean(e);
      notifyListeners();
      return false;
    }
  }

  // Returns {'tripName': ..., 'participantName': ...} or null on error
  Future<Map<String, String>?> validateInviteToken(String token) async {
    _isValidatingToken = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await validateInviteTokenUseCase.call(token);
      _isValidatingToken = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isValidatingToken = false;
      _errorMessage = _clean(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await logoutUseCase.call();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = _clean(e);
      notifyListeners();
      return false;
    }
  }
}
