class OwnerDiscussion {
  final String id;
  final String type;
  final String title;
  final String description;
  final int replyCount;
  final String createdAt;

  const OwnerDiscussion({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.replyCount,
    required this.createdAt,
  });
}
