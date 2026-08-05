import 'package:money_manager/domain/repositories/participant_repository.dart';

class GetProfileUseCase {
  final ParticipantRepository repository;

  GetProfileUseCase({required this.repository});

  Future<({String name, String email, String? avatarUrl})> call() => repository.getMe();
}
