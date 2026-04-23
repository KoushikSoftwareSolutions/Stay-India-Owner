import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.hostelId,
    required super.title,
    required super.content,
    super.createdAt,
    super.authorName,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['_id'] ?? json['id'] ?? '',
      hostelId: json['hostelId'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'],
      authorName: json['authorName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostelId': hostelId,
      'title': title,
      'content': content,
    };
  }
}
