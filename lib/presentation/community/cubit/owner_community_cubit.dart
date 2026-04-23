import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/owner_discussion.dart';
import '../../../domain/repositories/owner_community_repository.dart';

abstract class OwnerCommunityState {}

class OwnerCommunityInitial extends OwnerCommunityState {}

class OwnerCommunityLoading extends OwnerCommunityState {}

class OwnerCommunityLoaded extends OwnerCommunityState {
  final List<OwnerDiscussion> discussions;
  OwnerCommunityLoaded({required this.discussions});
}

class OwnerCommunityError extends OwnerCommunityState {
  final String message;
  OwnerCommunityError({required this.message});
}

class OwnerCommunityCubit extends Cubit<OwnerCommunityState> {
  final OwnerCommunityRepository ownerCommunityRepository;

  OwnerCommunityCubit({required this.ownerCommunityRepository})
      : super(OwnerCommunityInitial());

  Future<void> loadDiscussions(String hostelId) async {
    emit(OwnerCommunityLoading());
    try {
      final discussions =
          await ownerCommunityRepository.getDiscussions(hostelId);
      emit(OwnerCommunityLoaded(discussions: discussions));
    } catch (e) {
      emit(OwnerCommunityError(message: e.toString()));
    }
  }

  Future<void> createDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  }) async {
    emit(OwnerCommunityLoading());
    try {
      await ownerCommunityRepository.createDiscussion(
        title: title,
        description: description,
        type: type,
        hostelId: hostelId,
      );
      // Refresh list after creation
      if (hostelId != null) {
        await loadDiscussions(hostelId);
      }
    } catch (e) {
      emit(OwnerCommunityError(message: e.toString()));
    }
  }
}
