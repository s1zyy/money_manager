import 'package:money_manager/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase({required this.repository});

  Future<void> call() async {
    await repository.logout();
  }
}