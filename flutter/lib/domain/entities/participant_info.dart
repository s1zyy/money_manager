class ParticipantInfo {
  final String id;
  final String name;
  final bool isVirtual;
  final String? avatarUrl;

  ParticipantInfo({
    required this.id,
    required this.name,
    required this.isVirtual,
    this.avatarUrl,
  });
}