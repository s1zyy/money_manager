import 'package:money_manager/domain/repositories/participant_repository.dart';

class FullDeleteAccountUseCase {
  final ParticipantRepository repository;

  FullDeleteAccountUseCase({required this.repository});

  Future<void> call() {
    return repository.fullDeleteAccount();
  }
}
