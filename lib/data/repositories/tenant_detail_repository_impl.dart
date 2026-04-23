import '../../domain/entities/tenant_detail.dart';
import '../../domain/repositories/tenant_detail_repository.dart';
import '../data_sources/tenant_detail_remote_data_source.dart';

class TenantDetailRepositoryImpl implements TenantDetailRepository {
  final TenantDetailRemoteDataSource remoteDataSource;

  TenantDetailRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TenantDetail> getTenantDetail(String tenantId, String hostelId) {
    return remoteDataSource.getTenantDetail(tenantId, hostelId);
  }
}
