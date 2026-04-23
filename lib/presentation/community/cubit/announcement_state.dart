import 'package:equatable/equatable.dart';
import '../../../../domain/entities/announcement.dart';

abstract class AnnouncementState extends Equatable {
  const AnnouncementState();
  @override
  List<Object?> get props => [];
}

class AnnouncementInitial extends AnnouncementState {}

class AnnouncementLoading extends AnnouncementState {}

class AnnouncementLoaded extends AnnouncementState {
  final List<Announcement> announcements;
  const AnnouncementLoaded(this.announcements);
  @override
  List<Object?> get props => [announcements];
}

class AnnouncementPosting extends AnnouncementState {}

class AnnouncementPostSuccess extends AnnouncementState {}

class AnnouncementError extends AnnouncementState {
  final String message;
  const AnnouncementError(this.message);
  @override
  List<Object?> get props => [message];
}
