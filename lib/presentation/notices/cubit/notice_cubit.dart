import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/notice.dart';
import '../../../domain/repositories/notice_repository.dart';

abstract class NoticeState extends Equatable {
  const NoticeState();
  @override
  List<Object?> get props => [];
}

class NoticeInitial extends NoticeState {}

class NoticeSubmitting extends NoticeState {}

class NoticeSuccess extends NoticeState {}

class NoticeLoading extends NoticeState {}

class NoticesLoaded extends NoticeState {
  final List<Notice> notices;
  const NoticesLoaded({required this.notices});
  @override
  List<Object?> get props => [notices];
}

class NoticeUpdating extends NoticeState {}

class NoticeUpdateSuccess extends NoticeState {}

class NoticeLoadError extends NoticeState {
  final String message;
  const NoticeLoadError({required this.message});
  @override
  List<Object?> get props => [message];
}

class NoticeSubmitError extends NoticeState {
  final String message;
  const NoticeSubmitError({required this.message});
  @override
  List<Object?> get props => [message];
}

class NoticeUpdateError extends NoticeState {
  final String message;
  const NoticeUpdateError({required this.message});
  @override
  List<Object?> get props => [message];
}

class NoticeCubit extends Cubit<NoticeState> {
  final NoticeRepository noticeRepository;

  NoticeCubit({required this.noticeRepository}) : super(NoticeInitial());

  Future<void> createNotice({
    required String hostelId,
    required String tenantId,
    required String roomId,
    required String bedNumber,
    required String vacatingDate,
    String? reason,
  }) async {
    emit(NoticeSubmitting());
    try {
      await noticeRepository.createNotice(
        hostelId: hostelId,
        tenantId: tenantId,
        roomId: roomId,
        bedNumber: bedNumber,
        vacatingDate: vacatingDate,
        reason: reason,
      );
      emit(NoticeSuccess());
    } catch (e) {
      emit(NoticeSubmitError(message: e.toString()));
    }
  }

  Future<void> loadNotices({String? hostelId, String? status}) async {
    emit(NoticeLoading());
    try {
      final notices =
          await noticeRepository.getNotices(hostelId: hostelId, status: status);
      emit(NoticesLoaded(notices: notices));
    } catch (e) {
      emit(NoticeLoadError(message: e.toString()));
    }
  }

  Future<void> updateNotice(String id, Map<String, dynamic> data,
      {String? hostelId}) async {
    emit(NoticeUpdating());
    try {
      await noticeRepository.updateNotice(id, data);
      emit(NoticeUpdateSuccess());
      if (hostelId != null) {
        await loadNotices(hostelId: hostelId);
      }
    } catch (e) {
      emit(NoticeUpdateError(message: e.toString()));
    }
  }
}
