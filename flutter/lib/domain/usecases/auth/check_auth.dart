import 'package:money_manager/domain/repositories/auth_repository.dart';

class CheckAuthUseCase {
  final AuthRepository repository;

  CheckAuthUseCase({required this.repository});

  Future<bool> call() => repository.hasToken();
}
