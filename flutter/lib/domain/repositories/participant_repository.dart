abstract class ParticipantRepository {

  Future<Map<String, String>> getParticipantsMap(String tripId);
  }