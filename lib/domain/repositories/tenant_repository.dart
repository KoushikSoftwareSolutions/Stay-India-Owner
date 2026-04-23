import '../entities/tenant.dart';

abstract class TenantRepository {
  Future<List<Tenant>> getTenants({
    String status = 'CHECKED_IN',
    int page = 1,
    int limit = 20,
    String? search,
  });
  Future<void> addManualTenant({
    required String phone,
    required String hostelId,
    required String roomId,
    required String bedNumber,
    required double rent,
    String? firstName,
    String? lastName,
    String? sharingType,
    String? startDate,
    double? deposit,
  });
}
