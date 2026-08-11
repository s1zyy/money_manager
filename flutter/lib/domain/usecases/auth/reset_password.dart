import 'package:money_manager/domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase({required this.repository});

  Future<void> call(String token, String newPassword) => repository.resetPassword(token, newPassword);
}
