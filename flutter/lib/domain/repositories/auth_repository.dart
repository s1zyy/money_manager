import 'package:money_manager/domain/entities/auth_result.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(String email, String password, String name, {String? inviteToken});
  Future<void> logout();
  Future<bool> hasToken();
  Future<Map<String, dynamic>> validateInviteToken(String token);
  Future<AuthResult> claimInviteWithLogin(String token, String password);
}
