import '../entities/complaint.dart';

abstract class ComplaintsRepository {
  Future<List<Complaint>> getComplaints(String hostelId);
  Future<Complaint> getComplaintById(String id);
  Future<void> updateComplaint(String id, Map<String, dynamic> data);
}
