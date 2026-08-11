import 'package:money_manager/domain/repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository repository;

  ForgotPasswordUseCase({required this.repository});

  Future<void> call(String email) => repository.forgotPassword(email);
}
