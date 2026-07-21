import 'package:money_manager/domain/repositories/participant_repository.dart';

class DeleteAccountUseCase {
  final ParticipantRepository repository;

  DeleteAccountUseCase({required this.repository});

  Future<void> call() {
    return repository.deleteAccount();
  }
}
