import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/complaint.dart';
import '../../../domain/repositories/complaints_repository.dart';

abstract class ComplaintsState {}

class ComplaintsInitial extends ComplaintsState {}

class ComplaintsLoading extends ComplaintsState {}

class ComplaintsLoaded extends ComplaintsState {
  final List<Complaint> complaints;
  ComplaintsLoaded({required this.complaints});
}

class ComplaintUpdating extends ComplaintsState {}

class ComplaintUpdateSuccess extends ComplaintsState {
  final String message;
  ComplaintUpdateSuccess({this.message = 'Complaint updated'});
}

class ComplaintsError extends ComplaintsState {
  final String message;
  ComplaintsError({required this.message});
}

class ComplaintsCubit extends Cubit<ComplaintsState> {
  final ComplaintsRepository complaintsRepository;

  ComplaintsCubit({required this.complaintsRepository})
      : super(ComplaintsInitial());

  Future<void> loadComplaints(String hostelId) async {
    emit(ComplaintsLoading());
    try {
      final complaints = await complaintsRepository.getComplaints(hostelId);
      emit(ComplaintsLoaded(complaints: complaints));
    } catch (e) {
      emit(ComplaintsError(message: e.toString()));
    }
  }

  Future<void> updateComplaint(
      String id, Map<String, dynamic> data, String hostelId) async {
    emit(ComplaintUpdating());
    try {
      await complaintsRepository.updateComplaint(id, data);
      emit(ComplaintUpdateSuccess());
      await loadComplaints(hostelId);
    } catch (e) {
      emit(ComplaintsError(message: e.toString()));
    }
  }
}
