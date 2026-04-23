class CommunityMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final String createdAt;

  const CommunityMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.text,
    required this.createdAt,
  });
}
