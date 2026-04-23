import 'package:equatable/equatable.dart';

class Announcement extends Equatable {
  final String id;
  final String hostelId;
  final String title;
  final String content;
  final String? createdAt;
  final String? authorName;

  const Announcement({
    required this.id,
    required this.hostelId,
    required this.title,
    required this.content,
    this.createdAt,
    this.authorName,
  });

  @override
  List<Object?> get props => [id, hostelId, title, content, createdAt, authorName];
}
