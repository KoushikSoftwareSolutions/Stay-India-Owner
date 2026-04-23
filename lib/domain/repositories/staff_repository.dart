import '../entities/staff.dart';

abstract class StaffRepository {
  Future<List<Staff>> getStaff(String? hostelId);
  Future<Staff> getStaffById(String id);
  Future<void> createStaff({
    required String hostelId,
    required String name,
    required String phone,
    String? email,
    required String role,
    List<String>? permissions,
  });
  Future<void> updateStaff(String id, Map<String, dynamic> data);
  Future<void> logActivity(String id, String action, String? details);
}
