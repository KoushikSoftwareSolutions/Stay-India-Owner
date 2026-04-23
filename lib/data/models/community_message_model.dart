import '../../domain/entities/community_message.dart';

class CommunityMessageModel extends CommunityMessage {
  const CommunityMessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    required super.senderRole,
    required super.text,
    required super.createdAt,
  });

  factory CommunityMessageModel.fromJson(Map<String, dynamic> json) {
    return CommunityMessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      senderId: json['sender']?.toString() ?? json['senderId']?.toString() ?? '',
      senderName: json['senderName'] ?? '',
      senderRole: json['senderRole'] ?? '',
      text: json['text'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}
