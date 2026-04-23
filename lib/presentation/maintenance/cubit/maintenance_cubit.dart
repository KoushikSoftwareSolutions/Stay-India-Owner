import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/repositories/maintenance_repository.dart';

abstract class MaintenanceState extends Equatable {
  final TicketSummary? summary;
  const MaintenanceState({this.summary});
  @override
  List<Object?> get props => [summary];
}

class MaintenanceInitial extends MaintenanceState {}

class MaintenanceLoading extends MaintenanceState {
  const MaintenanceLoading({super.summary});
}

class MaintenanceLoaded extends MaintenanceState {
  const MaintenanceLoaded({required TicketSummary summary}) : super(summary: summary);
}

class MaintenanceSaving extends MaintenanceState {
  const MaintenanceSaving({super.summary});
}

class MaintenanceSuccess extends MaintenanceState {
  const MaintenanceSuccess({super.summary});
}

class MaintenanceError extends MaintenanceState {
  final String message;
  const MaintenanceError({required this.message, super.summary});
  @override
  List<Object?> get props => [message, summary];
}

class MaintenanceCubit extends Cubit<MaintenanceState> {
  final MaintenanceRepository maintenanceRepository;

  MaintenanceCubit({required this.maintenanceRepository})
      : super(MaintenanceInitial());

  Future<void> loadIssues({
    String? hostelId,
    String? status,
    String? search,
  }) async {
    emit(MaintenanceLoading(summary: state.summary));
    try {
      final summary = await maintenanceRepository.getIssues(
        hostelId: hostelId,
        status: status,
        search: search,
      );
      emit(MaintenanceLoaded(summary: summary));
    } catch (e) {
      emit(MaintenanceError(message: e.toString(), summary: state.summary));
    }
  }

  Future<void> createIssue({
    required String hostelId,
    required String title,
    String? description,
    String? roomId,
    String? bedNumber,
    String? status,
  }) async {
    emit(MaintenanceSaving(summary: state.summary));
    try {
      await maintenanceRepository.createIssue(
        hostelId: hostelId,
        title: title,
        description: description,
        roomId: roomId,
        bedNumber: bedNumber,
        status: status,
      );
      emit(MaintenanceSuccess(summary: state.summary));
    } catch (e) {
      emit(MaintenanceError(message: e.toString(), summary: state.summary));
    }
  }

  Future<void> updateIssue(
    String id, {
    String? title,
    String? description,
    String? status,
    String? assignedStaffId,
  }) async {
    emit(MaintenanceSaving(summary: state.summary));
    try {
      final data = <String, dynamic>{
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (status != null) 'status': status,
        if (assignedStaffId != null) 'assignedStaffId': assignedStaffId,
      };
      await maintenanceRepository.updateIssue(id, data);
      emit(MaintenanceSuccess(summary: state.summary));
    } catch (e) {
      emit(MaintenanceError(message: e.toString(), summary: state.summary));
    }
  }
}
