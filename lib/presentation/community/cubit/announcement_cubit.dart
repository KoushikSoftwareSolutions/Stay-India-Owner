import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/community_repository.dart';
import 'announcement_state.dart';

class AnnouncementCubit extends Cubit<AnnouncementState> {
  final CommunityRepository communityRepository;

  AnnouncementCubit({required this.communityRepository}) : super(AnnouncementInitial());

  Future<void> fetchAnnouncements(String hostelId) async {
    emit(AnnouncementLoading());
    try {
      final announcements = await communityRepository.getAnnouncements(hostelId);
      emit(AnnouncementLoaded(announcements));
    } catch (e) {
      emit(AnnouncementError(e.toString()));
    }
  }

  Future<void> postAnnouncement(String hostelId, String title, String content) async {
    emit(AnnouncementPosting());
    try {
      await communityRepository.postAnnouncement(hostelId, title, content);
      emit(AnnouncementPostSuccess());
      fetchAnnouncements(hostelId);
    } catch (e) {
      emit(AnnouncementError(e.toString()));
    }
  }
}
