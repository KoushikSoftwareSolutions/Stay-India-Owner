import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/staff.dart';
import '../../../domain/repositories/staff_repository.dart';

abstract class StaffState extends Equatable {
  const StaffState();
  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {}

class StaffLoading extends StaffState {}

class StaffLoaded extends StaffState {
  final List<Staff> staffList;
  const StaffLoaded({required this.staffList});
  @override
  List<Object?> get props => [staffList];
}

class StaffSaving extends StaffState {
  final List<Staff> staffList;
  const StaffSaving({required this.staffList});
  @override
  List<Object?> get props => [staffList];
}

class StaffSuccess extends StaffState {}

class StaffError extends StaffState {
  final String message;
  const StaffError({required this.message});
  @override
  List<Object?> get props => [message];
}

class StaffCubit extends Cubit<StaffState> {
  final StaffRepository staffRepository;

  StaffCubit({required this.staffRepository}) : super(StaffInitial());

  Future<void> loadStaff(String? hostelId) async {
    emit(StaffLoading());
    try {
      final staffList = await staffRepository.getStaff(hostelId);
      emit(StaffLoaded(staffList: staffList));
    } catch (e) {
      emit(StaffError(message: e.toString()));
    }
  }

  Future<void> createStaff({
    required String hostelId,
    required String name,
    required String phone,
    String? email,
    required String role,
    List<String>? permissions,
  }) async {
    final current = state is StaffLoaded
        ? (state as StaffLoaded).staffList
        : (state is StaffSaving ? (state as StaffSaving).staffList : <Staff>[]);
    emit(StaffSaving(staffList: current));
    try {
      await staffRepository.createStaff(
        hostelId: hostelId,
        name: name,
        phone: phone,
        email: email,
        role: role,
        permissions: permissions,
      );
      emit(StaffSuccess());
    } catch (e) {
      emit(StaffLoaded(staffList: current));
      emit(StaffError(message: e.toString()));
    }
  }

  Future<void> updateStaff(String id, Map<String, dynamic> data) async {
    final current = state is StaffLoaded
        ? (state as StaffLoaded).staffList
        : (state is StaffSaving ? (state as StaffSaving).staffList : <Staff>[]);
    emit(StaffSaving(staffList: current));
    try {
      await staffRepository.updateStaff(id, data);
      emit(StaffSuccess());
    } catch (e) {
      emit(StaffLoaded(staffList: current));
      emit(StaffError(message: e.toString()));
    }
  }

  Future<void> logActivity(String id, String action, String? details) async {
    final current = state is StaffLoaded
        ? (state as StaffLoaded).staffList
        : (state is StaffSaving ? (state as StaffSaving).staffList : <Staff>[]);
    emit(StaffSaving(staffList: current));
    try {
      await staffRepository.logActivity(id, action, details);
      emit(StaffSuccess());
    } catch (e) {
      emit(StaffLoaded(staffList: current));
      emit(StaffError(message: e.toString()));
    }
  }
}
