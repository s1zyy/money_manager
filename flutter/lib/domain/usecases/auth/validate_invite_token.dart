import 'package:money_manager/domain/repositories/auth_repository.dart';

class ValidateInviteTokenUseCase {
  final AuthRepository repository;

  ValidateInviteTokenUseCase({required this.repository});

  Future<Map<String, String>> call(String token) {
    return repository.validateInviteToken(token);
  }
}
