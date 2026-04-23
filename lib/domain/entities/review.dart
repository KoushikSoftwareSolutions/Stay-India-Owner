class Review {
  final String id;
  final String hostelId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final String createdAt;

  const Review({
    required this.id,
    required this.hostelId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
