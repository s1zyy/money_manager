import 'package:money_manager/domain/entities/participant_info.dart';

abstract class ParticipantRepository {
  Future<List<ParticipantInfo>> getParticipants(String tripId);
  Future<String> updateProfile(String name);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> deleteAccount();
  Future<void> fullDeleteAccount();
}