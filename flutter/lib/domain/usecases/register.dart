import 'package:money_manager/domain/entities/auth_result.dart';
import 'package:money_manager/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<AuthResult> call(String email, String password, String name) {
    return repository.register(email, password, name);
  }
}