import 'package:money_manager/domain/entities/auth_result.dart';
import 'package:money_manager/domain/repositories/auth_repository.dart';

class ClaimInviteWithLoginUseCase {
  final AuthRepository repository;

  ClaimInviteWithLoginUseCase({required this.repository});

  Future<AuthResult> call(String token, String password) {
    return repository.claimInviteWithLogin(token, password);
  }
}
