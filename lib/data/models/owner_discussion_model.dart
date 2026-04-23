import '../../domain/entities/owner_discussion.dart';

class OwnerDiscussionModel extends OwnerDiscussion {
  const OwnerDiscussionModel({
    required super.id,
    required super.type,
    required super.title,
    required super.description,
    required super.replyCount,
    required super.createdAt,
  });

  factory OwnerDiscussionModel.fromJson(Map<String, dynamic> json) {
    return OwnerDiscussionModel(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      replyCount: json['replyCount'] is int
          ? json['replyCount']
          : int.tryParse(json['replyCount']?.toString() ?? '0') ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
