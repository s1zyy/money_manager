import 'package:money_manager/domain/repositories/participant_repository.dart';

class UploadAvatarUseCase {
  final ParticipantRepository repository;
  UploadAvatarUseCase({required this.repository});

  Future<String> call(String filePath) => repository.uploadAvatar(filePath);
}
