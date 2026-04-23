import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.hostelId,
    required super.userId,
    required super.userName,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final userName = user != null
        ? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim()
        : json['userName']?.toString() ?? '';
    return ReviewModel(
      id: (json['_id'] ?? '').toString(),
      hostelId: (json['hostelId'] ?? json['hostel'] ?? '').toString(),
      userId: (json['userId'] ?? user?['_id'] ?? '').toString(),
      userName: userName.isEmpty ? 'Anonymous' : userName,
      rating: (json['rating'] is num)
          ? (json['rating'] as num).toDouble()
          : double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      comment: json['comment']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
