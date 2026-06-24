import 'package:money_manager/domain/entities/participant_info.dart';

abstract class ParticipantRepository {

  Future<List<ParticipantInfo>> getParticipants(String tripId);
  }