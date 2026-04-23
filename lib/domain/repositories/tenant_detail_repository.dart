import '../entities/tenant_detail.dart';

abstract class TenantDetailRepository {
  Future<TenantDetail> getTenantDetail(String tenantId, String hostelId);
}
