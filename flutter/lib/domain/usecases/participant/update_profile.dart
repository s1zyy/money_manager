import 'package:money_manager/domain/repositories/participant_repository.dart';

class UpdateProfileUseCase {
  final ParticipantRepository repository;

  UpdateProfileUseCase({required this.repository});

  Future<String> call(String name){
    return repository.updateProfile(name);
  }
}
