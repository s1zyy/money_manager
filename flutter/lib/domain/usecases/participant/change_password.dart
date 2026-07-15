import 'package:money_manager/domain/repositories/participant_repository.dart';

class ChangePasswordUseCase {
  final ParticipantRepository repository;

  ChangePasswordUseCase({required this.repository});

  Future<void> call(String currentPassword, String newPassword) {
    return repository.changePassword(currentPassword, newPassword);
  }
}
