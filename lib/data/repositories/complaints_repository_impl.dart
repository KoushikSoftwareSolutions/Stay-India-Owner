import '../../domain/entities/complaint.dart';
import '../../domain/repositories/complaints_repository.dart';
import '../data_sources/complaints_remote_data_source.dart';

class ComplaintsRepositoryImpl implements ComplaintsRepository {
  final ComplaintsRemoteDataSource remoteDataSource;

  ComplaintsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Complaint>> getComplaints(String hostelId) {
    return remoteDataSource.getComplaints(hostelId);
  }

  @override
  Future<Complaint> getComplaintById(String id) {
    return remoteDataSource.getComplaintById(id);
  }

  @override
  Future<void> updateComplaint(String id, Map<String, dynamic> data) {
    return remoteDataSource.updateComplaint(id, data);
  }
}
